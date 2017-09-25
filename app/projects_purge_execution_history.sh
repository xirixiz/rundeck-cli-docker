#!/bin/bash

##### Functions
function usage {
    echo -e "\nusage: $0 [--age <d,m,y>]"
    echo -e ""
    echo -e "  General parameters:"
    echo -e "    --age            specify purge after date (14d, 3m, 1y"
    echo -e "    --debug          debug mode"
    echo -e "    -?               help"
    exit 0
}

##### Posistional params
while [ $# -gt 0 ]; do
    case $1 in
      --age )          shift && export AGE="$1" ;;
      --debug )        DEBUG=debug ;;
      -? | --help )    usage && exit 0 ;;
      * )              echo -e "\nError: Unknown option: $1\n" >&2 && exit 1 ;;
    esac
    shift
done

##### Main
if [[ ! -z $DEBUG ]]; then set -x; fi
if [[ -z $AGE ]]; then echo "AGE not specified!" && exit 1; fi

export MAX="100" # Do not purge more than 100, Rundeck can't handle all requests and crashes.
export PROJECTS=$(/rundeck-cli/bin/rd projects list --outformat %name) # find all projecs in Rundeck

for i in ${PROJECTS}; do
  echo "Cleaning up job execution history for project: $i"
  while /rundeck-cli/bin/rd executions query --older ${AGE} --max ${MAX} -p $i | grep -q "more results"; do
    /rundeck-cli/bin/rd executions deletebulk --confirm --older ${AGE} --max ${MAX} -p $i
  done
done
