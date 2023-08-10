use crate::prelude::{api::*, *};

#[tonic::async_trait]
impl chat_server::Chat for ServiceContext {
    type SyncStream = Pin<Box<dyn Stream<Item = Result<sync::Events, Status>> + Send>>;

    async fn sync(&self, request: Request<sync::SyncInfo>) -> ApiResult<Self::SyncStream> {
        let user = request.user(&self.db).await?;
        let message = request.into_inner();

        let starting_at = message
            .last_updated
            .ok_or_else(|| Status::failed_precondition("missing last_updated"))?;

        let events = self.updater.get_updates(&user, &starting_at).await?;

        let rx = self.messenger.connect(user.id);

        self.messenger
            .send([user.id], events, false)
            .await
            .map_err(|e| {
                error!("failed to send initial sync event: {e:?}");
                Status::internal("an unexpected internal error occured")
            })?;

        Ok(Response::new(rx))
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

        let events = sync::Events {
            last_updated: Some(last_updated),
            events: vec![event],
        };

        self.messenger
            .send(users.into_iter().map(|u| u.id), events, true)
            .await
            .map_err(|e| {
                error!("failed to send message event: {:?}", anyhow::Error::from(e));
                Status::internal("an unexpected internal error occured")
            })?;

        Ok(Response::new(msg.into()))
    }
}
