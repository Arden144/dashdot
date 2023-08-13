use crate::prelude::{db::*, *};
pub use entity::msg::*;

pub struct MsgUpdateSource {
    db: DatabaseConnection,
}

impl MsgUpdateSource {
    pub fn new(db: DatabaseConnection) -> Self {
        Self { db }
    }
}

impl UpdateSource for MsgUpdateSource {
    type Item = msg::Model;

    async fn get_updates(
        &self,
        for_user: &user::Model,
        starting_at: DateTime,
    ) -> UpdateResult<Vec<Self::Item>> {
        Ok(for_user
            .find_related(chat::Entity)
            .find_with_related(msg::Entity)
            .filter(msg::Column::Date.gte(starting_at))
            .all(&self.db)
            .await
            .explanation("failed to get messages sent to user from database")?
            .into_iter()
            .flat_map(|(_, messages)| messages)
            .inspect(|msg| debug!("sending msg: {:?}", msg))
            .collect())
    }
}

pub async fn create_msg(
    db: &DatabaseConnection,
    msg: partial::NewMsg,
) -> DatabaseResult<msg::Model> {
    msg.into_active_model()
        .insert(db)
        .await
        .explanation("failed to add new message to database")
}
