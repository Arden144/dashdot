use crate::prelude::*;

#[pin_project(PinnedDrop)]
pub struct NotifyOnClose<T> {
    notifier: Option<oneshot::Sender<()>>,
    #[pin]
    receiver: mpsc::Receiver<T>,
}

#[pinned_drop]
impl<T> PinnedDrop for NotifyOnClose<T> {
    fn drop(self: Pin<&mut Self>) {
        let this = self.project();
        match this.notifier.take() {
            Some(notifier) => notifier
                .send(())
                .expect("notifier receive channel dropped before notification sent"),

            None => unreachable!("NotifyOnClose should never be created without a notifier"),
        }
    }
}

impl<T> Stream for NotifyOnClose<T> {
    type Item = T;

    fn poll_next(self: Pin<&mut Self>, cx: &mut task::Context<'_>) -> Poll<Option<Self::Item>> {
        let this = self.project();
        this.receiver.poll_next(cx)
    }

    fn size_hint(&self) -> (usize, Option<usize>) {
        self.receiver.size_hint()
    }
}

impl<T> NotifyOnClose<T> {
    pub fn new(notifier: oneshot::Sender<()>, receiver: mpsc::Receiver<T>) -> Self {
        Self {
            notifier: Some(notifier),
            receiver,
        }
    }
}
