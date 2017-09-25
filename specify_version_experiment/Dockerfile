FROM alpine
MAINTAINER Bram van Dartel <root@rootrulez.com>

ENV RD_AUTH_PROMPT false

RUN apk add --update bash \
 && apk add --update jq \
 && apk add --update unzip \
 && apk add --update wget \
 && apk add --update curl \
 && apk add --update openjdk8 \
 && rm -rf /var/cache/apk/*

COPY ["app/", "/app/"]
WORKDIR /app
RUN chmod +x *.sh

ENTRYPOINT ["sh", "entrypoint.sh"]
