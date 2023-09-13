use crate::prelude::*;

impl TryFrom<api::chat::Chat> for db::chat::Model {
    type Error = ConvertError;

    fn try_from(value: api::chat::Chat) -> Result<Self, Self::Error> {
        let Some(date) = value.date else {
            return Err(ConvertError::MissingRequiredField("date".to_string()))
        };

        Self {
            id: value.id,
            date: date.into_db_date(),
        }
        .into_ok()
    }
}

impl From<db::chat::Model> for api::chat::Chat {
    fn from(value: db::chat::Model) -> Self {
        Self {
            id: value.id,
            date: Some(value.date.into_api_date()),
        }
    }
}

impl From<db::chat::Model> for api::sync::Event {
    fn from(value: db::chat::Model) -> Self {
        Self {
            r#type: Some(api::sync::event::Type::Chat(value.into())),
        }
    }
}
