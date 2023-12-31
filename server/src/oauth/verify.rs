use crate::prelude::{oauth::*, *};

static DECODING_KEY: LazyLock<DecodingKey> = LazyLock::new(|| {
    let public_key = fs::read("secrets/public.pem").expect("failed to read public key");
    DecodingKey::from_ec_pem(&public_key).expect("failed to decode public key")
});

pub async fn verify(
    db: &DatabaseConnection,
    refresh_token: &str,
) -> Result<db::user::Model, OAuthError> {
    let mut validation = Validation::new(Algorithm::ES256);
    validation.set_issuer(&["com.ardensinclair.dashdot"]);

    let refresh_data = decode::<RefreshToken>(refresh_token, &DECODING_KEY, &validation)?;

    let user = db::user::user_by_sub(db, &refresh_data.claims.sub)
        .await?
        .ok_or(OAuthError::UserNotFound)?;

    let Some(ref jti) = user.jti else {
        return Err(OAuthError::InvalidRefreshToken.into());
    };

    if jti.as_str() != refresh_data.claims.jti {
        return Err(OAuthError::RefreshTokenUsed.into());
    };

    Ok(user)
}
