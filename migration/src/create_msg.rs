use sea_orm_migration::{prelude::*, sea_orm::DbBackend};

use crate::{create_chat::Chat, create_user::User};

#[derive(Iden)]
pub enum Msg {
    Table,
    Id,
    Text,
    Date,
    UserId,
    ChatId,
}

#[derive(DeriveMigrationName)]
pub struct Migration;

#[async_trait::async_trait]
impl MigrationTrait for Migration {
    async fn up(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        manager
            .create_table(
                Table::create()
                    .table(Msg::Table)
                    .if_not_exists()
                    .col(
                        ColumnDef::new(Msg::Id)
                            .integer()
                            .not_null()
                            .auto_increment()
                            .primary_key(),
                    )
                    .col(ColumnDef::new(Msg::Date).timestamp().not_null())
                    .col(ColumnDef::new(Msg::Text).string().not_null())
                    .col(ColumnDef::new(Msg::UserId).integer().not_null())
                    .col(ColumnDef::new(Msg::ChatId).integer().not_null())
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk-msg-user_id")
                            .from(Msg::Table, Msg::UserId)
                            .to(User::Table, User::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk-msg-chat_id")
                            .from(Msg::Table, Msg::ChatId)
                            .to(Chat::Table, Chat::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .to_owned(),
            )
            .await
    }

    async fn down(&self, manager: &SchemaManager) -> Result<(), DbErr> {
        if manager.get_database_backend() != DbBackend::Sqlite {
            manager
                .drop_foreign_key(
                    ForeignKey::drop()
                        .table(Msg::Table)
                        .name("fk-msg-user_id")
                        .to_owned(),
                )
                .await?;
            manager
                .drop_foreign_key(
                    ForeignKey::drop()
                        .table(Msg::Table)
                        .name("fk-msg-chat_id")
                        .to_owned(),
                )
                .await?;
        }

        manager
            .drop_table(Table::drop().table(Msg::Table).to_owned())
            .await
    }
}
