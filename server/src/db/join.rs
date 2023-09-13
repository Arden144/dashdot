use crate::prelude::{db::*, *};

pub async fn chat_with_users_by_id(
    db: &DatabaseConnection,
    id: i32,
) -> DatabaseResult<Option<(chat::Model, Vec<user::Model>)>> {
    chat::Entity::find_by_id(id)
        .find_with_related(user::Entity)
        .all(db)
        .await
        .explanation("failed to get chat by id with users from database")?
        .into_iter()
        .next()
        .into_ok()
}
