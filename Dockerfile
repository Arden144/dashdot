# syntax=docker/dockerfile:1

FROM rustlang/rust:nightly AS chef
WORKDIR /app
RUN cargo install cargo-chef
RUN apt-get update && apt-get install -y protobuf-compiler

FROM chef AS planner
COPY . .
RUN cargo chef prepare --recipe-path recipe.json

FROM chef AS builder
COPY --from=planner /app/recipe.json recipe.json
RUN cargo chef cook --release --recipe-path recipe.json
COPY . .
RUN cargo build --release

FROM debian:bullseye-slim AS runtime
WORKDIR /app
COPY --from=builder /app/target/release/dashdotserver /usr/local/bin
CMD ["/usr/local/bin/dashdotserver"]
EXPOSE 9090
