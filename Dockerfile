FROM alpine
MAINTAINER Bram van Dartel <root@rootrulez.com>

ENV RD_AUTH_PROMPT=false

RUN apk add --update bash \
 && apk add --update jq \
 && apk add --update unzip \
 && apk add --update wget \
 && apk add --update curl \
 && apk add --update openjdk8 \
 && rm -rf /var/cache/apk/*

RUN wget `curl -s https://api.github.com/repos/rundeck/rundeck-cli/releases | jq -r '.[] | .assets[0] | .browser_download_url' | grep zip | grep v1.0.17` -O /rundeck-cli.zip \
    && unzip rundeck-cli.zip -d /rundeck-cli \
    && mv /rundeck-cli/rd-*/* /rundeck-cli/

COPY ["app/", "/app/"]
WORKDIR /app
RUN chmod +x *.sh

ENTRYPOINT ["sh", "entrypoint.sh"]
