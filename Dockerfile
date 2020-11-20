# Replace with your app name
ARG APP_NAME="rust-template"

FROM clux/muslrust as cargo-build
ARG APP_NAME
WORKDIR /usr/src/${APP_NAME}

# Install Dependencies
COPY Cargo.toml Cargo.toml
RUN mkdir src/
RUN echo "fn main() {println!(\"if you see this, the build broke\")}" > src/main.rs
RUN cargo build --target x86_64-unknown-linux-musl --release
RUN rm -f target/x86_64-unknown-linux-musl/release/deps/${APP_NAME}*

# Build Code
COPY . .
RUN cargo build --target x86_64-unknown-linux-musl --release

# Extract Binary
FROM alpine:latest
ARG APP_NAME

# Handle signal handlers properly
RUN apk add --no-cache tini
COPY --from=cargo-build /usr/src/${APP_NAME}/target/x86_64-unknown-linux-musl/release/${APP_NAME} /usr/local/bin/${APP_NAME}

# CMD get evaluated at runtime, so ARG needs to be stored as ENV
ENV APP_NAME="${APP_NAME}"
CMD ${APP_NAME}
ENTRYPOINT ["/sbin/tini", "--"]
