use crate::prelude::db::*;

pub fn chat_members(chats: &[chat::Model], users: &[Vec<user::Model>]) -> Vec<member::Model> {
    chats
        .iter()
        .zip(users)
        .flat_map(|(chat, users)| {
            users.iter().map(|user| member::Model {
                chat_id: chat.id,
                user_id: user.id,
            })
        })
        .collect()
}
