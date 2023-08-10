use crate::prelude::{apns::*, *};

pub(super) static AUTH_HEADER: LazyLock<RwLock<String>> = LazyLock::new(|| {
    let token = create_token().expect("failed to create token");

    tokio::spawn(async {
        let mut interval = tokio::time::interval(Duration::new(60 * 30, 0));
        interval.set_missed_tick_behavior(MissedTickBehavior::Delay);
        interval.tick().await;

        loop {
            interval.tick().await;
            let new_token = create_token().expect("failed to create token");
            let mut token = AUTH_HEADER.write().await;
            *token = format!("bearer {new_token}");
        }
    });

    RwLock::new(format!("bearer {token}"))
});
