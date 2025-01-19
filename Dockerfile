FROM alpine:latest
RUN apk add --no-cache git sed
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
