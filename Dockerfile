FROM node:6-alpine

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /app && mkdir /config \
    && apk add --no-cache ca-certificates wget tar \
    && wget -O slack-irc.tar.gz https://github.com/ekmartin/slack-irc/archive/master.tar.gz \
    && tar --strip-components=1 -C /app/ -zxf slack-irc.tar.gz \
    && cd /app \
    && npm install && npm run build \
    && rm /slack-irc.tar.gz

WORKDIR /app

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["config.json"]
