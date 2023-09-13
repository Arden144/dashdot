use crate::prelude::*;

#[derive(Error, Debug)]
pub enum OAuthError {
    #[error("tried to modify tokens for a user that doesn't exist")]
    UserNotFound,
    #[error("invalid refresh token")]
    InvalidRefreshToken,
    #[error("refresh token has already been used")]
    RefreshTokenUsed,
    #[error("unexpected database error")]
    RawDatabaseError(#[from] DbErr),
    #[error("unexpected database error")]
    WrappedDatabaseError(#[from] db::DatabaseError),
    #[error("JWT encoding/decoding error")]
    JWTError(#[from] jsonwebtoken::errors::Error),
}
