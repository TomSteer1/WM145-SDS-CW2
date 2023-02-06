FROM rust:1.67.0

ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8080

WORKDIR /app
COPY . .

RUN rustup default nightly
RUN cargo build --release 

EXPOSE 8080

CMD ./target/release/rust-notebook
