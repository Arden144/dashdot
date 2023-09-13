use crate::prelude::*;

#[derive(Clone)]
pub struct ServiceContext {
    pub db: DatabaseConnection,
    pub messenger: Messenger,
    pub updater: Updater,
}

impl ServiceContext {
    pub fn new(db: DatabaseConnection, messenger: Messenger, updater: Updater) -> Self {
        Self {
            db,
            messenger,
            updater,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn assert_send<T: Send>() {}
    fn assert_sync<T: Sync>() {}

    #[test]
    fn ensure_auto_traits() {
        assert_send::<ServiceContext>();
        assert_sync::<ServiceContext>();
    }
}
