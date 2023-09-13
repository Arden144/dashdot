use crate::prelude::{api::*, apns::*, *};

static ENDPOINT: &'static str = "https://api.sandbox.push.apple.com";

static CLIENT: LazyLock<reqwest::Client> = LazyLock::new(|| {
    reqwest::Client::builder()
        .http2_prior_knowledge()
        .build()
        .expect("failed to build http client")
});

#[derive(Debug, Deserialize)]
pub(super) struct APNsErrorResponse {
    #[serde(default)]
    pub reason: Option<String>,
    #[serde(default)]
    pub timestamp: Option<u64>,
}

pub async fn send_notification(
    device_token: &[u8],
    msg: &msg::Msg,
    user: &user::User,
) -> Result<(), PushError> {
    debug!("sending push notification to user {}", user.id);
    let payload = json!({
        "aps": {
            "category": "MESSAGE",
            "mutable-content": 1,
            "alert": {
                "title": "New message",
                "subtitle": user.name,
                "body": msg.text
            }
        },
        "msgID": msg.id,
        "userID": msg.user_id,
        "chatID": msg.chat_id
    });

    let time = current_time().as_secs();

    let response = CLIENT
        .post(format!(
            "{}/3/device/{}",
            ENDPOINT,
            hex::encode(device_token)
        ))
        .header("authorization", AUTH_HEADER.read().await.as_str())
        .header("apns-push-type", "alert")
        .header("apns-expiration", time + 60 * 60 * 24 * 30)
        .header("apns-priority", 10)
        .header("apns-topic", "com.ardensinclair.dashdot")
        .json(&payload)
        .send()
        .await?;

    let status = response.status();
    let id = response
        .headers()
        .get("apns-id")
        .map_or("missing", |v| v.to_str().unwrap_or("malformed"));
    let debug_id = response
        .headers()
        .get("apns-unique-id")
        .map_or("missing", |v| v.to_str().unwrap_or("malformed"));

    info!(
        "APNs responded with (status: {}, id: {id}, debug_id: {debug_id})",
        status.as_u16()
    );

    if status == StatusCode::OK {
        response.bytes().await.ok();
        return Ok(());
    }

    match status {
        StatusCode::OK => {
            response.bytes().await.ok();
            Ok(())
        }
        _ => {
            let error_response = response.json::<APNsErrorResponse>().await.ok();
            let reason = apns_error_description(status, error_response);
            Err(PushError::ResponseError { status, reason })
        }
    }
}
