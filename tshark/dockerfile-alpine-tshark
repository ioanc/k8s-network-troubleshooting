FROM alpine:3.17.3
LABEL Author: ioan corcodel
COPY start.sh /
RUN apk --update --no-cache add tshark
RUN adduser -D user && addgroup user wireshark
RUN chgrp wireshark /usr/bin/dumpcap && chmod 4750 /usr/bin/dumpcap
USER user
CMD ["sh", "start.sh"]
