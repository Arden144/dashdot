use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    tonic_build::configure().build_client(false).compile(
        &[
            "./proto/msg.proto",
            "./proto/user.proto",
            "./proto/chat.proto",
            "./proto/sync.proto",
            "./proto/auth.proto",
            "./proto/push.proto",
            "./proto/api.proto",
        ],
        &["./proto"],
    )?;
    Ok(())
}
