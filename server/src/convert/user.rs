use crate::prelude::*;

impl From<db::user::Model> for api::user::User {
    fn from(value: db::user::Model) -> Self {
        Self {
            id: value.id,
            name: value.name,
            username: value.username,
        }
    }
}

impl From<db::user::Model> for api::sync::Event {
    fn from(value: db::user::Model) -> Self {
        Self {
            r#type: Some(api::sync::event::Type::User(value.into())),
        }
    }
}
