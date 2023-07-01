pub use sea_orm_migration::prelude::*;

mod create_chat;
mod create_member;
mod create_msg;
mod create_user;

pub struct Migrator;

#[async_trait::async_trait]
impl MigratorTrait for Migrator {
    fn migrations() -> Vec<Box<dyn MigrationTrait>> {
        vec![
            Box::new(create_user::Migration),
            Box::new(create_chat::Migration),
            Box::new(create_msg::Migration),
            Box::new(create_member::Migration),
        ]
    }
}
