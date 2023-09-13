use crate::prelude::{api::*, *};

async fn join_default_chat(
    db: &DatabaseConnection,
    messenger: &Messenger,
    time: Timestamp,
    user: &db::user::Model,
) -> anyhow::Result<()> {
    let member = db::member::ActiveModel {
        user_id: Set(user.id),
        chat_id: Set(1),
    }
    .insert(db)
    .await?;

    let (_, users) = db::join::chat_with_users_by_id(db, 1)
        .await?
        .expect("missing default conversation");

    let events = api::sync::Events {
        last_updated: Some(time),
        events: vec![user.clone().into(), member.into()],
    };

    messenger
        .send(users.into_iter().map(|u| u.id), events, true)
        .await
        .map_err(|e| {
            error!("failed to send events for user join: {e:?}");
            Status::internal("an unexpected internal error occured")
        })?;

    Ok(())
}

#[tonic::async_trait]
impl auth_server::Auth for ServiceContext {
    async fn pre_auth(&self, _request: Request<auth::NewSession>) -> ApiResult<auth::Session> {
        unimplemented!()
    }

    async fn auth(&self, request: Request<auth::NewAuth>) -> ApiResult<auth::Auth> {
        let message = request.into_inner();

        let sub = siwa::validate_auth_code(&message.authorization_code, &message.identity_token)
            .await
            .expect_error(|| {
                Status::permission_denied("failed to validate sign in with apple authorization")
            })?;

        let user = match db::user::user_by_sub(&self.db, &sub).await? {
            Some(user) => user,
            None => {
                let name = match message.full_name.as_str() {
                    "" => "User".to_owned(),
                    _ => message.full_name,
                };

                let username = match message.email.as_str() {
                    "" => Uuid::new_v4().as_hyphenated().to_string(),
                    _ => message.email,
                };

                let user = db::user::ActiveModel {
                    name: Set(name),
                    username: Set(username),
                    sub: Set(sub.clone()),
                    ..Default::default()
                };

                let user = user
                    .insert(&self.db)
                    .await
                    .expect_error(|| Status::internal("failed to add new user"))?;

                join_default_chat(
                    &self.db,
                    &self.messenger,
                    current_time().into_api_date(), // TODO: this is probably wrong
                    &user,
                )
                .await
                .expect_error(|| Status::internal("failed to join default chat"))?;

                user
            }
        };

        let user_id = user.id;

        let tokens = oauth::issue(&self.db, user)
            .await
            .expect_error(|| Status::internal("failed to issue tokens"))?;

        Ok(Response::new(auth::Auth {
            access_token: tokens.access_token,
            refresh_token: tokens.refresh_token,
            user_id,
        }))
    }

    async fn renew(&self, request: Request<auth::Renew>) -> ApiResult<auth::Auth> {
        let message = request.into_inner();

        let user = oauth::verify(&self.db, &message.refresh_token)
            .await
            .expect_error(|| Status::permission_denied("failed to verify refresh token"))?;

        let user_id = user.id;

        let tokens = oauth::issue(&self.db, user)
            .await
            .expect_error(|| Status::internal("failed to issue tokens"))?;

        Ok(Response::new(auth::Auth {
            access_token: tokens.access_token,
            refresh_token: tokens.refresh_token,
            user_id,
        }))
    }
}
