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

RUN wget --no-check-certificate $(wget -O- -q --no-check-certificate https://api.github.com/repos/rundeck/rundeck-cli/releases/latest | jq -r '.assets[].browser_download_url' | grep zip) -O /rundeck-cli.zip \
    && unzip rundeck-cli.zip -d /rundeck-cli \
    && mv /rundeck-cli/rd-*/* /rundeck-cli/

COPY ["app/", "/app/"]
WORKDIR /app
RUN chmod +x *.sh

#ENTRYPOINT ["/rundeck-cli/bin/rd"]
#CMD ["help"]
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
