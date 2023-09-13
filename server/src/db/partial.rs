use crate::prelude::{db::*, *};

pub struct NewMsg {
    pub text: String,
    pub date: Duration,
    pub user_id: i32,
    pub chat_id: i32,
}

impl NewMsg {
    pub fn into_active_model(self) -> msg::ActiveModel {
        msg::ActiveModel {
            text: Set(self.text),
            date: Set(self.date.into_db_date()),
            user_id: Set(self.user_id),
            chat_id: Set(self.chat_id),
            ..Default::default()
        }
    }
}
