use sea_orm_migration::{prelude::*, sea_orm::DbBackend};

use crate::{create_chat::Chat, create_user::User};

#[derive(Iden)]
pub enum Member {
    Table,
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
                    .table(Member::Table)
                    .if_not_exists()
                    .col(ColumnDef::new(Member::UserId).integer().not_null())
                    .col(ColumnDef::new(Member::ChatId).integer().not_null())
                    .primary_key(Index::create().col(Member::UserId).col(Member::ChatId))
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk-member-user_id")
                            .from(Member::Table, Member::UserId)
                            .to(User::Table, User::Id)
                            .on_delete(ForeignKeyAction::Cascade)
                            .on_update(ForeignKeyAction::Cascade),
                    )
                    .foreign_key(
                        ForeignKey::create()
                            .name("fk-member-chat_id")
                            .from(Member::Table, Member::ChatId)
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
                        .table(Member::Table)
                        .name("fk-member-user_id")
                        .to_owned(),
                )
                .await?;
            manager
                .drop_foreign_key(
                    ForeignKey::drop()
                        .table(Member::Table)
                        .name("fk-member-chat_id")
                        .to_owned(),
                )
                .await?;
        }
        manager
            .drop_table(Table::drop().table(Member::Table).to_owned())
            .await
    }
}
