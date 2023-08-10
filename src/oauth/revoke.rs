use crate::prelude::{oauth::*, *};

pub async fn revoke(db: &DatabaseConnection, sub: &str) -> Result<(), OAuthError> {
    let user = db::user::user_by_sub(db, sub)
        .await?
        .ok_or_else(|| OAuthError::UserNotFound)?;

    let mut user = db::user::ActiveModel::from(user);
    user.jti = Set(None);
    user.update(db).await?;

    Ok(())
}
