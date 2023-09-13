use crate::prelude::*;

pub fn create(context: ServiceContext) -> Router {
    let chat_svc =
        api::chat_server::ChatServer::with_interceptor(context.clone(), interceptor::auth);
    let push_svc =
        api::push_server::PushServer::with_interceptor(context.clone(), interceptor::auth);
    let auth_svc = api::auth_server::AuthServer::new(context);

    Server::builder()
        .add_service(chat_svc)
        .add_service(push_svc)
        .add_service(auth_svc)
}
