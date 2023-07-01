#![allow(dead_code)]
#![forbid(unsafe_code)]
#![feature(future_join)]
#![feature(async_fn_in_trait)]
#![feature(decl_macro)]
#![feature(lazy_cell)]
mod api;
mod convert;
mod db;
mod error;
mod helper;
mod interceptor;
mod oauth;
mod prelude;
mod request;
mod server;
mod service;
mod siwa;
mod stream;

use prelude::*;

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    dotenv()?;
    pretty_env_logger::init();

    let db_url = env::var("DATABASE_URL").context("missing DATABASE_URL in .env")?;
    let db = Database::connect(db_url).await?;

    let connections = Arc::new(DashMap::new());

    db::chat::ensure_default_chat(&db).await?;

    server::create(&db, &connections)
        .serve("0.0.0.0:9090".parse()?)
        .await?;

    Ok(())
}
