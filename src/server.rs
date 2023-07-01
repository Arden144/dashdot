use crate::prelude::*;

pub fn create(
    db: &DatabaseConnection,
    connections: &Arc<DashMap<i32, Sender<api::sync::Events>>>,
) -> Router {
    let app = service::ChatService::new(db.clone(), connections.clone());
    let auth = service::AuthService::new(db.clone(), connections.clone());
    let auth_svc = api::auth_server::AuthServer::new(auth);
    let secure_svc = api::chat_server::ChatServer::with_interceptor(app, interceptor::auth);

    Server::builder()
        .add_service(auth_svc)
        .add_service(secure_svc)
}
