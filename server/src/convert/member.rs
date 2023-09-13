use crate::prelude::*;

impl From<api::member::Member> for db::member::Model {
    fn from(value: api::member::Member) -> Self {
        Self {
            chat_id: value.chat_id,
            user_id: value.user_id,
        }
    }
}

impl From<db::member::Model> for api::member::Member {
    fn from(value: db::member::Model) -> Self {
        Self {
            chat_id: value.chat_id,
            user_id: value.user_id,
        }
    }
}

impl From<db::member::Model> for api::sync::Event {
    fn from(value: db::member::Model) -> Self {
        Self {
            r#type: Some(api::sync::event::Type::Member(value.into())),
        }
    }
}
