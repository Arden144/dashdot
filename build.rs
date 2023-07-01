use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    tonic_build::configure().build_client(false).compile(
        &[
            "../shared/proto/msg.proto",
            "../shared/proto/user.proto",
            "../shared/proto/chat.proto",
            "../shared/proto/sync.proto",
            "../shared/proto/auth.proto",
            "../shared/proto/api.proto",
        ],
        &["../shared/proto"],
    )?;
    Ok(())
}
