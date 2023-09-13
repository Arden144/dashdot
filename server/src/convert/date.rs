use crate::prelude::*;

pub trait IntoDbDate {
    fn into_db_date(&self) -> DateTime;
}

pub trait IntoApiDate {
    fn into_api_date(&self) -> Timestamp;
}

impl IntoDbDate for Timestamp {
    fn into_db_date(&self) -> DateTime {
        DateTime::from_timestamp_opt(self.seconds, self.nanos as u32)
            .expect("failed to convert Timestamp to DateTime")
    }
}

impl IntoDbDate for Duration {
    fn into_db_date(&self) -> DateTime {
        DateTime::from_timestamp_opt(self.as_secs() as i64, self.subsec_nanos())
            .expect("failed to convert Duration to DateTime")
    }
}

impl IntoApiDate for DateTime {
    fn into_api_date(&self) -> Timestamp {
        Timestamp {
            seconds: self.timestamp(),
            nanos: self.timestamp_subsec_nanos() as i32,
        }
    }
}

impl IntoApiDate for Duration {
    fn into_api_date(&self) -> Timestamp {
        Timestamp {
            seconds: self.as_secs() as i64,
            nanos: self.subsec_nanos() as i32,
        }
    }
}
