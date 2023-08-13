use crate::prelude::{api::*, *};

#[derive(Clone)]
pub struct Messenger {
    conn: Arc<DashMap<i32, Sender<sync::Events>>>,
    push: Arc<DashMap<i32, Box<[u8]>>>,
}

#[derive(Debug, Error)]
pub enum MessengerError {
    #[error("failed to send events")]
    SendFailed(#[from] futures_channel::mpsc::SendError),
    #[error("failed to send push notification")]
    PushFailed(#[from] PushError),
}

impl Messenger {
    pub fn new() -> Self {
        Self {
            conn: Arc::new(DashMap::new()),
            push: Arc::new(DashMap::new()),
        }
    }

    pub fn connect(
        &self,
        id: i32,
    ) -> Pin<Box<dyn Stream<Item = Result<sync::Events, Status>> + Send>> {
        let (tx, rx) = mpsc::channel::<sync::Events>(128);
        let conn = Arc::downgrade(&self.conn);
        let rx = rx.on_close(move || {
            let Some(conn) = conn.upgrade() else { return };
            info!("user {id} disconnected");
            conn.remove(&id);
        });

        self.conn.insert(id, tx);

        rx.map(Ok).boxed()
    }

    pub fn register(&self, id: i32, device_token: Box<[u8]>) {
        info!("user {id} registered for push notifications");
        self.push.insert(id, device_token);
    }

    pub async fn send(
        &self,
        ids: impl IntoIterator<Item = i32>,
        events: sync::Events,
        push: bool,
    ) -> Result<(), MessengerError> {
        let ids: Vec<i32> = ids.into_iter().collect();
        info!("sending event to users: {:?}", ids);
        debug!("event: {:?}", events);
        // TODO: This is a hack for testing only
        let db_url = env::var("DATABASE_URL").expect("failed to get DATABASE_URL from environment");
        let db = Database::connect(db_url)
            .await
            .expect("failed to connect to the database");
        for id in ids {
            if let Some(mut conn) = self.conn.get_mut(&id) {
                info!("user {id} is connected");
                conn.send(events.clone()).await?;
                continue;
            }

            if !push {
                warn!("user {id} is not connected but a direct notification was requested");
                continue;
            }

            // TODO: This is a hack for testing only
            if let Some(device_token) = self.push.get(&id) {
                info!("user {id} is available for push notifications");
                for event in events.events.iter() {
                    if let Some(sync::event::Type::Msg(ref msg)) = event.r#type {
                        let user = db::user::user_by_id(&db, msg.user_id)
                            .await
                            .expect("failed to get user for push notifications")
                            .expect("invalid user id")
                            .into();
                        send_notification(&device_token, msg, &user).await?;
                    } else {
                        warn!("unsupported event type for push notification");
                    }
                }
                continue;
            }

            info!("user {id} is not connected or available for push notifications");
        }

        Ok(())
    }
}
