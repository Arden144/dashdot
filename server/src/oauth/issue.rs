use crate::prelude::{oauth::*, *};

static ENCODING_KEY: LazyLock<EncodingKey> = LazyLock::new(|| {
    let private_key = fs::read("secrets/ec-private.pem").expect("failed to read private key");
    EncodingKey::from_ec_pem(&private_key).expect("failed to decode private key")
});

pub async fn issue(db: &DatabaseConnection, user: db::user::Model) -> Result<Tokens, OAuthError> {
    let iat = current_time().as_secs();
    let jti = Uuid::new_v4().hyphenated().to_string();

    let mut user: db::user::ActiveModel = user.into();
    user.jti = Set(Some(jti.clone()));
    let user = user.update(db).await?;

    let access_claims = AccessToken {
        iss: "com.ardensinclair.dashdot".to_owned(),
        sub: user.sub.to_owned(),
        exp: iat + 60 * 60,
        iat,
    };

    let refresh_claims = RefreshToken {
        iss: "com.ardensinclair.dashdot".to_owned(),
        sub: user.sub.to_owned(),
        exp: iat + 60 * 60 * 24 * 30,
        iat,
        jti,
    };

    let header = Header::new(Algorithm::ES256);

    Tokens {
        access_token: encode(&header, &access_claims, &ENCODING_KEY)?,
        refresh_token: encode(&header, &refresh_claims, &ENCODING_KEY)?,
    }
    .into_ok()
}
