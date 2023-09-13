use crate::prelude::*;

impl From<api::msg::NewMsg> for db::partial::NewMsg {
    fn from(value: api::msg::NewMsg) -> Self {
        Self {
            chat_id: value.chat_id,
            user_id: value.user_id,
            text: value.text,
            date: current_time(),
        }
    }
}
