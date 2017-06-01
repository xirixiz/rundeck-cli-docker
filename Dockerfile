FROM alpine
MAINTAINER Bram van Dartel <root@rootrulez.com>

RUN apk add --update bash \
 && apk add --update jq \
 && apk add --update unzip \
 && apk add --update wget \
 && apk add --update curl \
 && apk add --update openjdk8 \
 && rm -rf /var/cache/apk/*

RUN wget `curl -s https://api.github.com/repos/rundeck/rundeck-cli/releases/latest | jq --raw-output '.assets[0] | .browser_download_url'` -O /rundeck-cli.zip \
 && unzip rundeck-cli.zip -d /rundeck-cli \
 && mv /rundeck-cli/rd-*/* /rundeck-cli/

ENTRYPOINT ["/rundeck-cli/bin/rd"]
CMD ["help"]
