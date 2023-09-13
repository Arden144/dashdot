use crate::prelude::{apns::*, *};

fn apns_status_description(status: StatusCode) -> &'static str {
    match status {
        StatusCode::BAD_REQUEST => "Bad request",
        StatusCode::FORBIDDEN => {
            "There was an error with the certificate or with the provider’s authentication token"
        }
        StatusCode::NOT_FOUND => "The request contained an invalid :path value",
        StatusCode::METHOD_NOT_ALLOWED => {
            "The request used an invalid :method value. Only POST requests are supported"
        }
        StatusCode::GONE => "The device token is no longer active for the topic",
        StatusCode::PAYLOAD_TOO_LARGE => "The notification payload was too large",
        StatusCode::TOO_MANY_REQUESTS => {
            "The server received too many requests for the same device token"
        }
        StatusCode::INTERNAL_SERVER_ERROR => "Internal server error",
        StatusCode::SERVICE_UNAVAILABLE => "The server is shutting down and unavailable",
        _ => "Unknown error",
    }
}

fn apns_reason_description(reason: &str) -> Option<&'static str> {
    match reason {
        "BadCollapseId" => Some("The collapse identifier exceeds the maximum allowed size"),
        "BadDeviceToken" => Some("The specified device token is invalid. Verify that the request contains a valid token and that the token matches the environment"),
        "BadExpirationDate" => Some("The apns-expiration value is invalid"),
        "BadMessageId" => Some("The apns-id value is invalid"),
        "BadPriority" => Some("The apns-priority value is invalid"),
        "BadTopic" => Some("The apns-topic value is invalid"),
        "DeviceTokenNotForTopic" => Some("The device token doesn't match the specified topic"),
        "DuplicateHeaders" => Some("One or more headers are repeated"),
        "IdleTimeout" => Some("Idle timeout"),
        "InvalidPushType" => Some("The apns-push-type value is invalid"),
        "MissingDeviceToken" => Some("The device token isn't specified in the request :path. Verify that the :path header contains the device token"),
        "MissingTopic" => Some("The apns-topic header of the request isn't specified and is required. The apns-topic header is mandatory when the client is connected using a certificate that supports multiple topics"),
        "PayloadEmpty" => Some("The message payload is empty"),
        "TopicDisallowed" => Some("Pushing to this topic is not allowed"),
        "BadCertificate" => Some("The certificate is invalid"),
        "BadCertificateEnvironment" => Some("The client certificate is for the wrong environment"),
        "ExpiredProviderToken" => Some("The provider token is stale and a new token should be generated"),
        "Forbidden" => Some("The specified action is not allowed"),
        "InvalidProviderToken" => Some("The provider token is not valid, or the token signature can't be verified"),
        "MissingProviderToken" => Some("No provider certificate was used to connect to APNs and the authorization header is missing or no provider token is specified"),
        "BadPath" => Some("The request contained an invalid :path value"),
        "MethodNotAllowed" => Some("The specified :method value isn't POST"),
        "ExpiredToken" => Some("The device token has expired"),
        "Unregistered" => Some("The device token is inactive for the specified topic"),
        "PayloadTooLarge" => Some("The message payload is too large"),
        "TooManyProviderTokenUpdates" => Some("The provider's authentication token is being updated too often. Update the authentication token no more than once every 20 minutes"),
        "TooManyRequests" => Some("Too many requests were made consecutively to the same device token"),
        "InternalServerError" => Some("An internal server error occurred"),
        "ServiceUnavailable" => Some("The service is unavailable"),
        "Shutdown" => Some("The APNs server is shutting down"),
        _ => None,
    }
}

pub(super) fn apns_error_description(
    status: StatusCode,
    error_response: Option<APNsErrorResponse>,
) -> String {
    error_response
        .and_then(|e| e.reason)
        .and_then(|r| apns_reason_description(&r))
        .unwrap_or_else(|| apns_status_description(status))
        .to_owned()
}

#[derive(Debug, Error)]
pub enum PushError {
    #[error("failed to create token")]
    TokenEncodeError(#[from] jsonwebtoken::errors::Error),
    #[error("APNs request failed to send")]
    RequestFailed(#[from] reqwest::Error),
    #[error("APNs request failed ({}): {reason}", .status.as_u16())]
    ResponseError { status: StatusCode, reason: String },
}
