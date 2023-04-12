FROM alpine:3.17.3
LABEL Author: ioan corcodel
COPY start.sh /
RUN apk --update --no-cache add tshark
CMD ["sh", "start.sh"]
