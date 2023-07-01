use crate::prelude::*;

#[derive(Error, Debug)]
#[error("Unexpected database error: {context}\n\nCaused by: {source:?}")]
pub struct UnexpectedDbError {
    source: DbErr,
    context: String,
}

impl From<UnexpectedDbError> for Status {
    fn from(value: UnexpectedDbError) -> Self {
        let context = value.context.clone();
        error!("{:?}", anyhow::Error::from(value));
        Status::internal(context)
    }
}

pub(super) trait DbErrExt<T> {
    fn explanation<S: ToString>(self, context: S) -> DbResult<T>;
}

impl<T> DbErrExt<T> for Result<T, DbErr> {
    fn explanation<S: ToString>(self, context: S) -> DbResult<T> {
        self.map_err(|source| UnexpectedDbError {
            source,
            context: context.to_string(),
        })
    }
}

pub type DbResult<T> = Result<T, UnexpectedDbError>;
