use crate::prelude::*;

pub trait RequestExt<T> {
    fn sub(&self) -> Result<&str, Status>;
    async fn user(&self, db: &DatabaseConnection) -> Result<db::user::Model, Status>;
}

impl<T> RequestExt<T> for Request<T> {
    fn sub(&self) -> Result<&str, Status> {
        self.extensions()
            .get::<oauth::AccessToken>()
            .ok_or_else(|| {
                error!("failed to get sub from request metadata");
                Status::internal("an unexpected internal error occured")
            })?
            .sub
            .as_str()
            .into_ok()
    }

    async fn user(&self, db: &DatabaseConnection) -> Result<db::user::Model, Status> {
        let sub = self.sub()?;

        db::user::user_by_sub(db, sub)
            .await?
            .ok_or_else(|| Status::permission_denied("user does not exist"))
    }
}
