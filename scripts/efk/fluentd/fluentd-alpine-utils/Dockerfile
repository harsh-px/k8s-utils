# Utils image which contains jq and curl.
FROM alpine
MAINTAINER hrishikesh.deodhar@gmail.com

RUN apk update \
 && apk add --update curl \
 && apk add jq \
 && rm -rf /var/cache/apk/*

COPY init-fluentd.sh /usr/bin

