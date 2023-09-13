use crate::prelude::*;

mod auth;
mod chat;
mod context;
mod push;

pub use auth::*;
pub use chat::*;
pub use context::*;
pub use push::*;

pub type ApiResult<T> = Result<Response<T>, Status>;
