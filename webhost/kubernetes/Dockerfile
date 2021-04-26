#
# A very basic docker image for the web host
#

FROM node:15.11.0-alpine
RUN apk --no-cache add curl
RUN apk --no-cache add openssl

WORKDIR /usr/spa
COPY webhost/index.html /usr/spa
COPY webhost/server.js /usr/spa

RUN addgroup -g 1001 webgroup
RUN adduser -u 1001 -G webgroup -h /home/webuser -D webuser
USER webuser
CMD ["node", "server.js"]
