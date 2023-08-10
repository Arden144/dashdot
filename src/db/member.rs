use crate::prelude::{db::*, *};
pub use entity::member::*;

pub struct MemberUpdateSource {
    db: DatabaseConnection,
}

impl MemberUpdateSource {
    pub fn new(db: DatabaseConnection) -> Self {
        Self { db }
    }
}

impl UpdateSource for MemberUpdateSource {
    type Item = member::Model;

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
            .zip(chats)
            .flat_map(|(users, chat)| {
                users.into_iter().map(move |user| member::Model {
                    chat_id: chat.id,
                    user_id: user.id,
                })
            })
            .inspect(|member| debug!("sending member: {member:?}"))
            .collect())
    }
}
