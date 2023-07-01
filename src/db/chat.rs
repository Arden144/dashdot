use crate::prelude::{db::*, *};
pub use entity::chat::*;

pub async fn chats_by_user(
    db: &DatabaseConnection,
    user: &user::Model,
) -> DbResult<Vec<chat::Model>> {
    user.find_related(chat::Entity)
        .all(db)
        .await
        .explanation("failed to get user's chats from database")
}

pub async fn ensure_default_chat(db: &DatabaseConnection) -> DbResult<chat::Model> {
    let chat = chat::Entity::find_by_id(1)
        .one(db)
        .await
        .explanation("failed to get default chat from database")?;
    if let Some(chat) = chat {
        return Ok(chat);
    }

    chat::ActiveModel {
        id: Set(1),
        date: Set(current_time().into_db_date()),
    }
    .insert(db)
    .await
    .explanation("failed to insert default chat into database")
}
