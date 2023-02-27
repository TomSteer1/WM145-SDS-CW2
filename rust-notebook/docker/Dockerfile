# Build Stage
FROM rustlang/rust:nightly-alpine as builder
LABEL maintainer="Oscar Sharpe <oscar.sharpe@warwick.ac.uk>"
LABEL version="0.1.0"

WORKDIR /code
RUN apk update \
    && apk add build-base openssl-dev zlib-dev  \
    && rm -rf /var/cache/apk/*
COPY . .
RUN cargo build --release

# Image Stage
FROM alpine:latest
LABEL maintainer="Oscar Sharpe <oscar.sharpe@warwick.ac.uk>"
LABEL version="0.1.0"

ENV ROCKET_ENV=production \
    ROCKET_ADDRESS=0.0.0.0 ROCKET_PORT=8080 \
    ROCKET_LOG=critical

EXPOSE 8080

COPY --from=builder /code/target/release/rust-notebook /usr/local/bin/rust-notebook
CMD rust-notebook
