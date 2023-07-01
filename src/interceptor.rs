use crate::prelude::*;

static DECODING_KEY: LazyLock<DecodingKey> = LazyLock::new(|| {
    let public_key = fs::read("secrets/public.pem").expect("failed to read public key");
    DecodingKey::from_ec_pem(&public_key).unwrap()
});

pub fn auth(mut request: Request<()>) -> Result<Request<()>, Status> {
    let authorization = request
        .metadata()
        .get("authorization")
        .ok_or_else(|| Status::unauthenticated("missing access token"))?;

    let (bearer, access_token) = authorization
        .to_str()
        .expect_error(|| Status::failed_precondition("invalid characters in authorization header"))?
        .split(' ')
        .next_tuple()
        .ok_or_else(|| Status::failed_precondition("invalid authorization header"))?;

    precondition!(bearer == "Bearer", "invalid authorization header");

    let mut validation = Validation::new(Algorithm::ES256);
    validation.set_issuer(&["com.ardensinclair.dashdot"]);

    let access_data = decode::<oauth::AccessToken>(access_token, &DECODING_KEY, &validation)
        .expect_error(|| Status::permission_denied("invalid access token"))?;

    request.extensions_mut().insert(access_data.claims);

    Ok(request)
}
