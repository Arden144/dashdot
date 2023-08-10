use crate::prelude::*;

#[derive(Error, Debug)]
pub enum UpdateError {
    #[error("Failed to get updates from database")]
    DatabaseError(#[from] db::DatabaseError),
}

impl From<UpdateError> for Status {
    fn from(value: UpdateError) -> Self {
        let error = anyhow::Error::from(value);
        error!("Failed to get updates: {error:?}");
        Status::internal("an unexpected internal error occured")
    }
}

pub type UpdateResult<T> = Result<T, UpdateError>;

pub trait UpdateSource {
    type Item: Into<api::sync::Event>;

    async fn get_updates(
        &self,
        for_user: &db::user::Model,
        starting_at: DateTime,
    ) -> UpdateResult<Vec<Self::Item>>;
}

pub trait SendUpdateSource
where
    Self: UpdateSource<get_updates(): Send> + Send + Sync,
{
}

impl<T> SendUpdateSource for T where T: UpdateSource<get_updates(): Send> + Send + Sync {}

trait UpdateSourceDyn: Send + Sync {
    fn get_updates<'a>(
        &'a self,
        for_user: &'a db::user::Model,
        starting_at: DateTime,
    ) -> Pin<Box<dyn Future<Output = UpdateResult<Vec<api::sync::Event>>> + Send + 'a>>;
}

impl<T: SendUpdateSource> UpdateSourceDyn for T {
    fn get_updates<'a>(
        &'a self,
        for_user: &'a db::user::Model,
        starting_at: DateTime,
    ) -> Pin<Box<dyn Future<Output = UpdateResult<Vec<api::sync::Event>>> + Send + 'a>> {
        Box::pin(async move {
            self.get_updates(for_user, starting_at)
                .await
                .map(|updates| updates.into_iter().map(Into::into).collect())
        })
    }
}

#[derive(Clone)]
pub struct Updater {
    sources: Arc<Box<[Box<dyn UpdateSourceDyn>]>>,
}

pub struct UpdaterBuilder {
    sources: Vec<Box<dyn UpdateSourceDyn>>,
}

impl UpdaterBuilder {
    fn new() -> Self {
        Self {
            sources: Vec::new(),
        }
    }

    pub fn register_source(mut self, source: impl SendUpdateSource + 'static) -> Self {
        self.sources.push(Box::new(source));
        self
    }

    pub fn done(self) -> Updater {
        Updater::new(self.sources)
    }
}

impl Updater {
    pub fn builder() -> UpdaterBuilder {
        UpdaterBuilder::new()
    }

    pub async fn get_updates(
        &self,
        for_user: &db::user::Model,
        starting_at: &Timestamp,
    ) -> UpdateResult<api::sync::Events> {
        let mut events = Vec::new();
        let starting_at = starting_at.into_db_date();

        for source in self.sources.iter() {
            events.append(&mut source.get_updates(for_user, starting_at).await?);
        }

        Ok(api::sync::Events {
            last_updated: None,
            events,
        })
    }

    fn new(sources: Vec<Box<dyn UpdateSourceDyn>>) -> Self {
        Self {
            sources: Arc::new(sources.into_boxed_slice()),
        }
    }
}
