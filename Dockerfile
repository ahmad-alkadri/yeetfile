# syntax=docker/dockerfile:1

FROM alpine:latest AS builder

WORKDIR /app

RUN apk add --no-cache go npm make git
RUN npm install -g typescript@5.5.4

COPY go.mod go.sum ./
RUN go mod download

COPY backend/ ./backend
COPY utils/ ./utils
COPY web/ ./web
COPY shared/ ./shared
COPY tsconfig.json .

COPY Makefile .

# Manually clone submodules to avoid copying .git
RUN rm -rf backend/static/stream_saver && \
    git clone https://github.com/benbusby/StreamSaver.js.git backend/static/stream_saver && \
    rm -rf backend/static/js && \
    git clone https://git.sr.ht/~benbusby/yeetfile-js backend/static/js

RUN make backend

# Server image
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/yeetfile-server /app
RUN chmod +x /app/yeetfile-server
EXPOSE 8090

CMD ["/app/yeetfile-server"]
