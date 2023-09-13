use crate::prelude::*;

#[derive(Error, Debug)]
pub enum ConvertError {
    #[error("missing required field: {0}")]
    MissingRequiredField(String),
}
