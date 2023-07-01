use crate::prelude::*;

pub mod auth;
pub mod chat;

pub use auth::*;
pub use chat::*;

pub type ApiResult<T> = Result<Response<T>, Status>;
