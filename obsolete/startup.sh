#!/bin/bash

# Dockerfile entries
#COPY scripts/startup.sh /
#RUN chmod +x /startup.sh
#ENTRYPOINT ["/startup.sh"]

echo -e "\nRundeck CLI version to be installed: v${RD_CLI_VERSION}\n"
wget --no-check-certificate https://github.com/rundeck/rundeck-cli/releases/download/v${RD_CLI_VERSION}/rd-${RD_CLI_VERSION}.zip -O /rundeck-cli.zip
unzip rundeck-cli.zip -d /rundeck-cli

/rundeck-cli/rd-${RD_CLI_VERSION}/bin/rd
