FROM node:6-alpine

RUN mkdir /app \
    && mkdir /slack-irc \
    && apk add --no-cache ca-certificates wget tar \
    && wget -O slack-irc.tar.gz https://github.com/ekmartin/slack-irc/archive/master.tar.gz \
    && tar --strip-components=1 -C /slack-irc/ -zxf slack-irc.tar.gz \
    && cd /slack-irc \
    && npm install && npm run build \
    && rm /slack-irc.tar.gz

WORKDIR /slack-irc

ENTRYPOINT ["npm", "start", "--", "--config"]
CMD ["/app/config.json"]
