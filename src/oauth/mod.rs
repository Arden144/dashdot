mod issue;
mod revoke;
mod verify;

pub use issue::*;
pub use revoke::*;
pub use verify::*;

use crate::prelude::*;

#[derive(Error, Debug)]
pub enum OAuthError {
    #[error("tried to modify tokens for a user that doesn't exist")]
    UserNotFound,
    #[error("invalid refresh token")]
    InvalidRefreshToken,
    #[error("refresh token has already been used")]
    RefreshTokenUsed,
}

pub struct Tokens {
    pub access_token: String,
    pub refresh_token: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AccessToken {
    pub iss: String,
    pub sub: String,
    pub exp: u64,
    pub iat: u64,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RefreshToken {
    pub iss: String,
    pub sub: String,
    pub exp: u64,
    pub iat: u64,
    pub jti: String,
}
