use crate::prelude::*;

static TEAM_ID: LazyLock<&'static str> = LazyLock::new(|| {
    Box::leak(
        env::var("TEAM_ID")
            .expect("missing TEAM_ID in env")
            .into_boxed_str(),
    )
});

static KID: LazyLock<&'static str> = LazyLock::new(|| {
    Box::leak(
        env::var("KID")
            .expect("missing KID in env")
            .into_boxed_str(),
    )
});

static ENCODING_KEY: LazyLock<EncodingKey> = LazyLock::new(|| {
    let private_key = fs::read("secrets/siwa-private.p8").expect("failed to read private key");
    EncodingKey::from_ec_pem(&private_key).expect("failed to decode private key")
});

#[derive(Debug, Serialize)]
struct Token {
    iss: String,
    iat: u64,
}

pub(super) fn create_token() -> Result<String, PushError> {
    info!("creating new apns token");
    let time = current_time().as_secs();

    let mut header = Header::new(Algorithm::ES256);
    header.kid = Some(KID.to_owned());

    let claims = Token {
        iss: TEAM_ID.to_owned(),
        iat: time,
    };

    encode(&header, &claims, &ENCODING_KEY).map_err(|e| e.into())
}
