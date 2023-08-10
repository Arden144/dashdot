use crate::prelude::{db::*, *};
pub use entity::user::*;

pub struct UserUpdateSource {
    db: DatabaseConnection,
}

impl UserUpdateSource {
    pub fn new(db: DatabaseConnection) -> Self {
        Self { db }
    }
}

impl UpdateSource for UserUpdateSource {
    type Item = user::Model;

    async fn get_updates(
        &self,
        for_user: &user::Model,
        _starting_at: DateTime,
    ) -> UpdateResult<Vec<Self::Item>> {
        let chats = for_user
            .find_related(chat::Entity)
            .all(&self.db)
            .await
            .explanation("failed to get user's chats from database")?;

        Ok(chats
            .load_many_to_many(user::Entity, member::Entity, &self.db)
            .await
            .explanation("failed to get user's friends from database")?
            .into_iter()
            .flatten()
            .unique_by(|user| user.id)
            .inspect(|user| debug!("sending user: {user:?}"))
            .collect())
    }
}

pub async fn user_by_sub(
    db: &DatabaseConnection,
    sub: &str,
) -> DatabaseResult<Option<user::Model>> {
    user::Entity::find()
        .filter(user::Column::Sub.eq(sub))
        .one(db)
        .await
        .explanation("failed to get user by sub")
}

pub async fn user_by_id(db: &DatabaseConnection, id: i32) -> DatabaseResult<Option<user::Model>> {
    user::Entity::find_by_id(id)
        .one(db)
        .await
        .explanation("failed to get user by id")
}
