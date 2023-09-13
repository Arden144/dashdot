use crate::prelude::*;

pub macro chained {
    ($x:expr, $($xs:expr),+) => { $x.chain(chained!($($xs),+)) },
    ($x:expr) => { $x }
}

pub macro precondition($cond:expr, $reason:expr) {
    if !$cond {
        return Err(Status::failed_precondition($reason));
    }
}

pub trait IntoOkResult {
    fn into_ok<E>(self) -> Result<Self, E>
    where
        Self: Sized;
}

impl<T: Sized> IntoOkResult for T {
    #[inline]
    fn into_ok<E>(self) -> Result<Self, E> {
        Ok(self)
    }
}

pub trait IntoErrResult {
    fn into_err<T>(self) -> Result<T, Self>
    where
        Self: Sized;
}

impl<E: Sized> IntoErrResult for E {
    #[inline]
    fn into_err<T>(self) -> Result<T, Self> {
        Err(self)
    }
}

pub trait IntoAnyhowErrResult {
    fn into_anyhow_err<T>(self) -> anyhow::Result<T>
    where
        Self: Sized + Into<anyhow::Error>;
}

impl<E> IntoAnyhowErrResult for E
where
    E: Sized + Into<anyhow::Error>,
{
    #[inline]
    fn into_anyhow_err<T>(self) -> anyhow::Result<T> {
        Err(self.into())
    }
}

pub fn current_time() -> Duration {
    SystemTime::now()
        .duration_since(SystemTime::UNIX_EPOCH)
        .expect("system time is before unix epoch")
}
