FROM golang:1.21.1-alpine3.18 AS build

RUN apk add \
      binutils \
      git \
      make

WORKDIR /app

# Download modules as separate step for caching.
COPY go.mod go.sum ./
RUN go mod download

COPY . ./
RUN make clean && make


# Final stage for service.
FROM alpine:3.18.3

RUN apk update && \
    apk upgrade && \
    rm -rf /var/cache/apk/*

COPY --from=build /app/bin/qnapexporter .
ENTRYPOINT ["./qnapexporter"]
