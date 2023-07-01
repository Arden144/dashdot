use crate::prelude::{db::*, *};
pub use entity::msg::*;

pub async fn msgs_by_chats(
    db: &DatabaseConnection,
    chats: &[chat::Model],
    since: DateTime,
) -> DbResult<Vec<msg::Model>> {
    chats
        .load_many(msg::Entity::find().filter(msg::Column::Date.gte(since)), db)
        .await
        .explanation("failed to get messages by chats from database")?
        .into_iter()
        .flatten()
        .collect::<Vec<_>>()
        .into_ok()
}

pub async fn create_msg(db: &DatabaseConnection, msg: partial::NewMsg) -> DbResult<msg::Model> {
    msg.into_active_model()
        .insert(db)
        .await
        .explanation("failed to add new message to database")
}
