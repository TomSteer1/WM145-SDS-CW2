FROM alpine

ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8080

WORKDIR /app
COPY /rust-notebook-alpine .

EXPOSE 8080

CMD chmod +x ./rust-notebook-alpine && ./rust-notebook-alpine
