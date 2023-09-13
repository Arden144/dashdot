use crate::prelude::*;

#[derive(Error, Debug)]
#[error("Unexpected database error: {context}")]
pub struct DatabaseError {
    #[source]
    source: DbErr,
    context: String,
}

impl From<DatabaseError> for Status {
    fn from(value: DatabaseError) -> Self {
        let context = value.context.clone();
        error!("{:?}", anyhow::Error::from(value));
        Status::internal(context)
    }
}

pub(super) trait DatabaseResultExt<T> {
    fn explanation(self, context: impl ToString) -> DatabaseResult<T>;
}

impl<T> DatabaseResultExt<T> for Result<T, DbErr> {
    fn explanation(self, context: impl ToString) -> DatabaseResult<T> {
        self.map_err(|source| DatabaseError {
            source,
            context: context.to_string(),
        })
    }
}

pub type DatabaseResult<T> = Result<T, DatabaseError>;
