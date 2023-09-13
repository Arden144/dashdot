use crate::prelude::{api::*, *};

#[tonic::async_trait]
impl push_server::Push for ServiceContext {
    async fn register(&self, request: Request<push::Register>) -> ApiResult<push::Registered> {
        let user = request.user(&self.db).await?;
        let message = request.into_inner();

        self.messenger
            .register(user.id, message.device_token.into_boxed_slice());

        Ok(Response::new(push::Registered {}))
    }
}
