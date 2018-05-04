FROM ubuntu:16.04
LABEL Name="rundeck-cli" Version="latest" Maintainer="Bram van Dartel <root@rootrulez.com>"

ENV DEBIAN_FRONTEND=noninteractive
ENV RD_AUTH_PROMPT=false
ENV TERM=xterm-256color

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      sudo \
      debconf-utils \
      apt-utils \
      apt-transport-https \
      ca-certificates \
      git \
      jq \
      curl \
      wget \
      software-properties-common \
      openjdk-8-jdk

RUN echo "deb https://rundeck.bintray.com/rundeck-deb /" | tee -a /etc/apt/sources.list && \
    wget -qO - https://bintray.com/user/downloadSubjectPublicKey?username=bintray | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y rundeck-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ["app/", "/app/"]
WORKDIR /app

RUN chmod +x *.sh
ENTRYPOINT ["./entrypoint.sh"]
