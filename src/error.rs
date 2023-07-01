use crate::prelude::*;

#[derive(Error, Debug)]
#[error("Handled database error: {}\nOriginal error:\n{source:?}", .status.message())]
pub struct HandledError {
    source: anyhow::Error,
    status: Status,
}

impl From<HandledError> for Status {
    fn from(value: HandledError) -> Self {
        info!("{value}");
        value.status
    }
}

pub trait ExpectError<T> {
    fn expect_error(self, status: impl FnOnce() -> Status) -> Result<T, HandledError>;
}

impl<T, E: Into<anyhow::Error>> ExpectError<T> for Result<T, E> {
    fn expect_error(self, status: impl FnOnce() -> Status) -> Result<T, HandledError> {
        self.map_err(|source| HandledError {
            source: source.into(),
            status: status(),
        })
    }
}
