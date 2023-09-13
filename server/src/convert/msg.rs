use crate::prelude::*;

impl TryFrom<api::msg::Msg> for db::msg::Model {
    type Error = ConvertError;

    fn try_from(value: api::msg::Msg) -> Result<Self, Self::Error> {
        let Some(date) = value.date else {
            return Err(ConvertError::MissingRequiredField("date".to_string()))
        };

        Self {
            id: value.id,
            date: date.into_db_date(),
            chat_id: value.chat_id,
            user_id: value.user_id,
            text: value.text,
        }
        .into_ok()
    }
}

impl From<db::msg::Model> for api::msg::Msg {
    fn from(value: db::msg::Model) -> Self {
        Self {
            id: value.id,
            date: Some(value.date.into_api_date()),
            chat_id: value.chat_id,
            user_id: value.user_id,
            text: value.text,
        }
    }
}

impl From<db::msg::Model> for api::msg::MsgSent {
    fn from(value: db::msg::Model) -> Self {
        Self {
            id: value.id,
            date: Some(value.date.into_api_date()),
        }
    }
}

impl From<db::msg::Model> for api::sync::Event {
    fn from(value: db::msg::Model) -> Self {
        Self {
            r#type: Some(api::sync::event::Type::Msg(value.into())),
        }
    }
}
