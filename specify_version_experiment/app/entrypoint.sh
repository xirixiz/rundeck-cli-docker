#!/bin/bash
set -e

script=$1

if [[ -z $RD_URL ]]; then echo "RD_URL not specified!" && exit 1; fi
if [[ -z $RD_TOKEN ]]; then echo "RD_TOKEN not specified!" && exit 1; fi
if [[ -z $RD_CLI_VERSION ]]; then echo "RD_CLI_VERSION not specified!" && exit 1; fi

echo -e "\nRundeck CLI version to be installed: v${RD_CLI_VERSION}\n"
wget --no-check-certificate $(wget -O- -q --no-check-certificate https://api.github.com/repos/rundeck/rundeck-cli/releases/tags/v${RD_CLI_VERSION} | jq -r '.assets[].browser_download_url' | grep zip) -O /rundeck-cli.zip \
unzip rundeck-cli.zip -d /rundeck-cli
/rundeck-cli/rd-*/* /rundeck-cli/

if [[ ${script} == "rd" ]]; then
  shift
  /rundeck-cli/bin/rd $*
else
  shift
  sh $script.sh $*
fi
