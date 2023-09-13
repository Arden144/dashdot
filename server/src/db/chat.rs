use crate::prelude::{db::*, *};
pub use entity::chat::*;

pub struct ChatUpdateSource {
    db: DatabaseConnection,
}

impl ChatUpdateSource {
    pub fn new(db: DatabaseConnection) -> Self {
        Self { db }
    }
}

impl UpdateSource for ChatUpdateSource {
    type Item = chat::Model;

    async fn get_updates(
        &self,
        for_user: &user::Model,
        starting_at: DateTime,
    ) -> UpdateResult<Vec<Self::Item>> {
        let chats = for_user
            .find_related(chat::Entity)
            .filter(chat::Column::Date.gte(starting_at))
            .all(&self.db)
            .await
            .explanation("failed to get user's chats from database")?;

        for chat in chats.iter() {
            debug!("sending chat: {chat:?}");
        }

        Ok(chats)
    }
}

pub async fn ensure_default_chat(db: &DatabaseConnection) -> DatabaseResult<chat::Model> {
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
