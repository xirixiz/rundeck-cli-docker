#!/bin/sh
set -eu

if [[ -z $RD_URL ]]; then echo "RD_URL not specified!" && exit 1; fi
if [[ -z $RD_TOKEN ]]; then echo "RD_TOKEN not specified!" && exit 1; fi

script=$1

if [[ ${script} == "rd" ]]; then
  shift
  /rundeck-cli/bin/rd "$@"
else
  shift
  bash $script.sh "$@"
fi

