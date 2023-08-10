use crate::prelude::*;

#[pin_project(PinnedDrop)]
pub struct OnCloseWrapper<T, F>
where
    F: FnOnce() -> (),
{
    #[pin]
    wrapped: mpsc::Receiver<T>,
    func: Option<F>,
}

#[pinned_drop]
impl<T, F> PinnedDrop for OnCloseWrapper<T, F>
where
    F: FnOnce() -> (),
{
    fn drop(self: Pin<&mut Self>) {
        let this = self.project();
        let func = this.func.take().expect("func should never be None");
        func();
    }
}

impl<T, F> Stream for OnCloseWrapper<T, F>
where
    F: FnOnce() -> (),
{
    type Item = T;

    fn poll_next(self: Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Option<Self::Item>> {
        let this = self.project();
        this.wrapped.poll_next(cx)
    }

    fn size_hint(&self) -> (usize, Option<usize>) {
        self.wrapped.size_hint()
    }
}

pub trait ChannelOnClose<T, F>
where
    Self: Sized,
    F: FnOnce() -> (),
{
    fn on_close(self, func: F) -> OnCloseWrapper<T, F>;
}

impl<T, F> ChannelOnClose<T, F> for mpsc::Receiver<T>
where
    F: FnOnce() -> (),
{
    fn on_close(self, func: F) -> OnCloseWrapper<T, F> {
        OnCloseWrapper {
            wrapped: self,
            func: Some(func),
        }
    }
}
