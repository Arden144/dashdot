pub mod chat {
    tonic::include_proto!("chat");
}

pub mod user {
    tonic::include_proto!("user");
}

pub mod msg {
    tonic::include_proto!("msg");
}

pub mod member {
    tonic::include_proto!("member");
}

pub mod sync {
    tonic::include_proto!("sync");
}

pub mod auth {
    tonic::include_proto!("auth");
}

pub mod push {
    tonic::include_proto!("push");
}

mod api {
    tonic::include_proto!("api");

    pub use super::user::User;
}

pub use api::*;
