#![deny(unsafe_code)]
#![allow(dead_code)]
#![allow(non_snake_case)]
// return type notation is experimental/incomplete, but needed for Send async traits
#![allow(incomplete_features)]
#![feature(future_join)]
#![feature(async_fn_in_trait)]
#![feature(return_type_notation)]
#![feature(decl_macro)]
#![feature(lazy_cell)]
mod api;
mod apns;
mod convert;
mod db;
mod error;
mod helper;
mod interceptor;
mod messenger;
mod oauth;
mod prelude;
mod request;
mod server;
mod service;
mod siwa;
mod stream;
mod update;

use migration::{Migrator, MigratorTrait};
use prelude::*;

async fn connect_db(opt: impl Into<sea_orm::ConnectOptions> + Clone) -> DatabaseConnection {
    let mut interval = tokio::time::interval(Duration::new(3, 0));
    loop {
        interval.tick().await;
        match Database::connect(opt.clone()).await {
            Ok(db) => return db,
            Err(err) => {
                log::warn!("failed to connect to the database: {err:?}");
            }
        }
    }
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv()?;
    pretty_env_logger::init();

    log::info!("starting dashdot");

    let db_url = env::var("DATABASE_URL").context("missing DATABASE_URL in .env")?;
    let db = connect_db(db_url).await;
    Migrator::up(&db, None)
        .await
        .context("failed to run database migrations")?;

    let messenger = Messenger::new();

    let updater = Updater::builder()
        .register_source(db::user::UserUpdateSource::new(db.clone()))
        .register_source(db::chat::ChatUpdateSource::new(db.clone()))
        .register_source(db::member::MemberUpdateSource::new(db.clone()))
        .register_source(db::msg::MsgUpdateSource::new(db.clone()))
        .done();

    db::chat::ensure_default_chat(&db).await?;

    server::create(ServiceContext::new(db, messenger, updater))
        .serve("0.0.0.0:9090".parse()?)
        .await?;

    Ok(())
}
