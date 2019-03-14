FROM golang:1.9.2-alpine

#WORKDIR /go/src/github.com/tylertreat/comcast

RUN apk update && \
    apk add git && \
    apk add make && \
    go get github.com/tylertreat/comcast && \
    go install github.com/tylertreat/comcast

