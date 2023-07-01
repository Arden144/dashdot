use crate::prelude::{api::*, *};

pub struct ChatService {
    db: DatabaseConnection,
    connections: Arc<DashMap<i32, Sender<sync::Events>>>,
}

impl ChatService {
    pub fn new(
        db: DatabaseConnection,
        connections: Arc<DashMap<i32, Sender<sync::Events>>>,
    ) -> Self {
        Self { db, connections }
    }
}

#[tonic::async_trait]
impl chat_server::Chat for ChatService {
    type SyncStream = Pin<Box<dyn Stream<Item = Result<sync::Events, Status>> + Send>>;

    async fn sync(&self, request: Request<sync::SyncInfo>) -> ApiResult<Self::SyncStream> {
        let user = request.user(&self.db).await?;
        let message = request.into_inner();

        let since = message
            .last_updated
            .ok_or_else(|| Status::failed_precondition("missing last_updated"))?
            .into_db_date();

        let (notifier, closed) = oneshot::channel();
        let (mut tx, rx) = mpsc::channel::<sync::Events>(128);
        let rx = NotifyOnClose::new(notifier, rx);

        tokio::spawn({
            let connections = self.connections.clone();
            async move {
                closed.await.expect("notification channel canceled");
                connections.remove(&user.id);
            }
        });

        let now = SystemTime::now()
            .duration_since(UNIX_EPOCH)
            .expect("failed to get current time");

        let chats = db::chat::chats_by_user(&self.db, &user).await?;
        let users = db::user::users_by_chats(&self.db, &chats).await?;
        let msgs = db::msg::msgs_by_chats(&self.db, &chats, since).await?;
        let members = db::helper::chat_members(&chats, &users);

        let events = sync::Events {
            last_updated: Some(now.into_api_date()),
            events: chained![
                chats.into_iter().map(Into::into),
                users
                    .into_iter()
                    .flatten()
                    .unique_by(|u| u.id)
                    .map(Into::into),
                msgs.into_iter().map(Into::into),
                members.into_iter().map(Into::into)
            ]
            .collect(),
        };

        tx.send(events).await.map_err(|e| {
            error!("failed to send initial sync event: {e:?}");
            Status::internal("an unexpected internal error occured")
        })?;

        self.connections.insert(user.id, tx);

        Ok(Response::new(rx.map(Ok).boxed()))
    }

    async fn send_msg(&self, request: Request<msg::NewMsg>) -> ApiResult<msg::MsgSent> {
        let user = request.user(&self.db).await?;
        let message = request.into_inner();

        precondition!(message.user_id == user.id, "user id does not match");

        let (_, users) = db::join::chat_with_users_by_id(&self.db, message.chat_id)
            .await?
            .ok_or_else(|| Status::failed_precondition("not a member of the given chat"))?;

        precondition!(
            users.iter().any(|u| u.id == user.id),
            "not a member of the given chat"
        );

        let msg = db::msg::create_msg(&self.db, message.into()).await?;
        let event: sync::Event = msg.clone().into();
        let last_updated = msg.date.into_api_date();

        for user in users {
            let Some(mut tx) = self.connections.get_mut(&user.id) else { continue };

            tx.send(sync::Events {
                last_updated: Some(last_updated.clone()),
                events: vec![event.clone()],
            })
            .await
            .map_err(|e| {
                error!("failed to send message event: {e:?}");
                Status::internal("an unexpected internal error occured")
            })?;
        }

        Ok(Response::new(msg.into()))
    }
}
