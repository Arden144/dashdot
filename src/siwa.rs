use crate::prelude::*;

static APPLE_API_AUTH_TOKEN: &'static str = "https://appleid.apple.com/auth/token";
static VALID_FOR: u64 = 15_768_000; // 6 months in seconds

static KID: LazyLock<&'static str> = LazyLock::new(|| {
    Box::leak(
        env::var("KID")
            .expect("missing KID in env")
            .into_boxed_str(),
    )
});

static TEAM_ID: LazyLock<&'static str> = LazyLock::new(|| {
    Box::leak(
        env::var("TEAM_ID")
            .expect("missing TEAM_ID in env")
            .into_boxed_str(),
    )
});

static APP_ID: LazyLock<&'static str> = LazyLock::new(|| {
    Box::leak(
        env::var("APP_ID")
            .expect("missing APP_ID in env")
            .into_boxed_str(),
    )
});

static CLIENT_ID: LazyLock<&'static str> = LazyLock::new(|| {
    Box::leak(
        env::var("CLIENT_ID")
            .expect("missing CLIENT_ID in env")
            .into_boxed_str(),
    )
});

static ENCODING_KEY: LazyLock<EncodingKey> = LazyLock::new(|| {
    let private_key = fs::read("secrets/siwa-private.p8").expect("failed to read private key");
    EncodingKey::from_ec_pem(&private_key).unwrap()
});

static CLIENT: LazyLock<reqwest::Client> = LazyLock::new(reqwest::Client::new);

// https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
#[derive(Debug, Serialize, Deserialize)]
struct ClientSecret<'a> {
    aud: &'a str, // https://appleid.apple.com
    exp: u64,     // up to 6 months from current time in seconds
    iat: u64,     // time we generated the client secret in UNIX epoch time in seconds
    iss: &'a str, // Apple Developer Team ID
    sub: &'a str, // Client ID used in SIWA token request
}

impl ClientSecret<'_> {
    fn new(time: u64) -> Self {
        Self {
            aud: "https://appleid.apple.com",
            exp: time + VALID_FOR,
            iat: time,
            iss: *TEAM_ID,
            sub: *APP_ID,
        }
    }
}

// https://developer.apple.com/documentation/sign_in_with_apple/sign_in_with_apple_rest_api/authenticating_users_with_sign_in_with_apple
#[derive(Debug, Deserialize)]
struct IdentityToken {
    iss: String,           // https://appleid.apple.com
    sub: String,           // unique identifier for the user
    aud: String,           // Apple Developer Client ID
    iat: i64,              // time the token was issued in seconds since UNIX epoch time
    exp: i64,              // expiration time in seconds since UNIX epoch time
    nonce: Option<String>, // session nonce
    nonce_supported: bool, // if nonce missing and this is true, fail, else succeed
}

// https://developer.apple.com/documentation/sign_in_with_apple/jwkset
#[derive(Debug, Deserialize)]
struct JWKSet {
    keys: Vec<JWK>, // An array that contains JSON Web Key objects.
}

// https://developer.apple.com/documentation/sign_in_with_apple/jwkset/keys
#[derive(Debug, Deserialize)]
struct JWK {
    alg: String, // The encryption algorithm used to encrypt the token.
    e: String,   // The exponent value for the RSA public key.
    kid: String, // A 10-character identifier key, obtained from your developer account.
    kty: String, // The key type parameter setting. You must set to "RSA".
    n: String,   // The modulus value for the RSA public key.
    #[serde(rename = "use")]
    usage: String, // The intended use for the public key.
}

// https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
#[derive(Debug, Serialize)]
struct ValidateGrantCode<'a> {
    client_id: &'a str,
    client_secret: &'a str,
    code: &'a str,
    grant_type: &'a str,
}

// https://developer.apple.com/documentation/sign_in_with_apple/generate_and_validate_tokens
#[derive(Debug, Serialize)]
struct ValidateRefreshToken<'a> {
    client_id: &'a str,
    client_secret: &'a str,
    grant_type: &'a str,
    refresh_token: &'a str,
}

// https://developer.apple.com/documentation/sign_in_with_apple/tokenresponse
#[derive(Debug, Deserialize)]
struct TokenResponse {
    access_token: String,
    expires_in: usize,
    id_token: String,
    refresh_token: String,
    token_type: String,
}

// https://developer.apple.com/documentation/sign_in_with_apple/errorresponse
#[derive(Debug, Deserialize)]
struct ErrorResponse {
    error: String,
}

#[derive(Error, Debug)]
pub enum SIWAError {
    #[error("missing KID in identity token header")]
    MissingKID,
    #[error("no JWK matching KID")]
    NoValidJWK,
    #[error("request to {0} failed: {1:?}")]
    RequestFailed(String, #[source] anyhow::Error),
}

async fn decode_identity_token(token: &str) -> anyhow::Result<TokenData<IdentityToken>> {
    let jwks = CLIENT
        .get("https://appleid.apple.com/auth/keys")
        .send()
        .await?
        .error_for_status()?
        .json::<JWKSet>()
        .await?;

    let header = decode_header(token).context("failed to decode identity token header")?;
    let Some(kid) = header.kid else {
		return Err(SIWAError::MissingKID.into())
	};

    let jwk = jwks
        .keys
        .into_iter()
        .find(|jwk| jwk.kid == kid)
        .ok_or(SIWAError::NoValidJWK)?;

    let key = DecodingKey::from_rsa_components(&jwk.n, &jwk.e)?;

    let mut validation = Validation::new(Algorithm::RS256);
    validation.set_issuer(&["https://appleid.apple.com"]);
    validation.set_audience(&[*APP_ID]);

    decode::<IdentityToken>(token, &key, &validation).context("failed to decode identity token")
}

pub async fn validate_auth_code(code: &str, identity_token: &str) -> anyhow::Result<String> {
    let mut header = Header::new(Algorithm::ES256);
    header.kid = Some(KID.to_string());

    let time = current_time().as_secs();
    let client_secret = ClientSecret::new(time);

    let client_secret = encode(&header, &client_secret, &ENCODING_KEY)
        .context("failed to encode client_secret JWT")?;

    let form = ValidateGrantCode {
        client_id: *APP_ID,
        client_secret: &client_secret,
        code,
        grant_type: "authorization_code",
    };

    let res = CLIENT
        .post(APPLE_API_AUTH_TOKEN)
        .form(&form)
        .send()
        .await
        .context("failed to send request")
        .map_err(|e| SIWAError::RequestFailed(APPLE_API_AUTH_TOKEN.to_owned(), e))?;

    if res.status() != StatusCode::OK {
        let error = res
            .json::<ErrorResponse>()
            .await
            .context("failed to deserialize error message")?
            .error;
        return SIWAError::RequestFailed(APPLE_API_AUTH_TOKEN.to_owned(), anyhow::anyhow!(error))
            .into_anyhow_err();
    }

    let data = res
        .json::<TokenResponse>()
        .await
        .context("failed to deserialize token message")
        .map_err(|e| SIWAError::RequestFailed(APPLE_API_AUTH_TOKEN.to_owned(), e))?;

    let identity_data = decode_identity_token(identity_token).await?;

    // TODO: store refresh token in database

    // TODO: verify nonce

    identity_data.claims.sub.into_ok()
}

async fn validate_refresh_token(refresh_token: &str) -> anyhow::Result<String> {
    let client = reqwest::Client::new();

    let mut header = Header::new(Algorithm::ES256);
    header.kid = Some(KID.to_string());

    let time = current_time().as_secs();
    let claims = ClientSecret {
        aud: "https://appleid.apple.com",
        exp: time + VALID_FOR,
        iat: time,
        iss: *TEAM_ID,
        sub: *APP_ID,
    };

    let client_secret =
        encode(&header, &claims, &ENCODING_KEY).context("failed to encode client_secret JWT")?;

    let form = ValidateRefreshToken {
        client_id: *APP_ID,
        client_secret: &client_secret,
        grant_type: "refresh_token",
        refresh_token,
    };

    let res = client
        .post(APPLE_API_AUTH_TOKEN)
        .form(&form)
        .send()
        .await
        .context("failed to send request")
        .map_err(|e| SIWAError::RequestFailed(APPLE_API_AUTH_TOKEN.to_owned(), e))?;

    match res.status() {
        StatusCode::OK => res
            .json::<TokenResponse>()
            .await
            .context("failed to deserialize token message")
            .map_err(|e| SIWAError::RequestFailed(APPLE_API_AUTH_TOKEN.to_owned(), e))?
            .refresh_token
            .into_ok(),
        _ => {
            let error = res
                .json::<ErrorResponse>()
                .await
                .context("failed to deserialize error message")?
                .error;
            SIWAError::RequestFailed(APPLE_API_AUTH_TOKEN.to_owned(), anyhow::anyhow!(error))
                .into_anyhow_err()
        }
    }
}
