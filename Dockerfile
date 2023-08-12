FROM rustlang/rust:nightly AS build-env
WORKDIR /app
COPY . /app
RUN apt-get update && \
    apt-get install -y protobuf-compiler && \
    cargo build --profile dist

FROM gcr.io/distroless/cc
COPY --from=build-env /app/target/dist/dashdotserver /
CMD ["./dashdotserver"]
