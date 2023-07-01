use crate::prelude::{db::*, *};
pub use entity::user::*;

pub async fn users_by_chats(
    db: &DatabaseConnection,
    chats: &[chat::Model],
) -> DbResult<Vec<Vec<user::Model>>> {
    chats
        .load_many_to_many(user::Entity, member::Entity, db)
        .await
        .explanation("failed to get users by chats from database")
}

pub async fn user_by_sub(db: &DatabaseConnection, sub: &str) -> DbResult<Option<user::Model>> {
    user::Entity::find()
        .filter(user::Column::Sub.eq(sub))
        .one(db)
        .await
        .explanation("failed to get user by sub")
}
