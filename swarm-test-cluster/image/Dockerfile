# Build Geth in a stock Go builder container
FROM golang:1.10-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers

COPY go-ethereum /go/src/github.com/ethereum/go-ethereum

RUN cd /go/src/github.com/ethereum/go-ethereum && \
    go install ./cmd/bootnode && \
    go install ./cmd/geth && \
    go install ./cmd/swarm

# Pull all binaries into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go/bin/* /usr/local/bin/

COPY content/account.sh /account.sh
COPY content/run-bootnode.sh /run-bootnode.sh
COPY content/run-geth.sh /run-geth.sh
COPY content/run-swarm.sh /run-swarm.sh

# Temporary password in order to run swarm non-interactively
COPY content/password /password

CMD ["geth"]