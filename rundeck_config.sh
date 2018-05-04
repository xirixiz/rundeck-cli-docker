#!/bin/bash

### Constants
export GIT_NAMESPACE=rundeck-projects
export GIT_URL=git.domain
export GIT_API_VERSION=4
export GIT_PROJECTS=`curl -Ssl -k --header "PRIVATE-TOKEN: ${GIT_TOKEN}" "http://${GIT_URL}/api/v${GIT_API_VERSION}/groups/${GIT_NAMESPACE}" | jq --raw-output --compact-output ".projects[] | select(.namespace.name == \"${GIT_NAMESPACE}\" and .archived == false) | .name"`
export RD_API_VERSION=23
export RD_HTTP_TIMEOUT=56600


##### Functions
function usage {
    echo -e "\nusage: $0 [--age <d,m,y>]"
    echo -e ""
    echo -e "  General parameters:"
    echo -e "    --delete         delete existing projects."
    echo -e "    --configure      reconfigure existing projects."
    echo -e "    --debug          debug mode."
    echo -e "    -?               help."
    exit 0
}

function delete {
  for k in `rd projects list --outformat "%name"`; do
    echo "Deleting all project data for: $k"
    rd executions deletebulk --confirm -y --older 1h --max 1000 -p $k
    rd projects delete -p $k --confirm -y
  done

  if rd keys list -p "keys/AMS" 2> /dev/null | grep -F "keys/AMS/${GIT_USER}" > /dev/null; then
    echo "Resource found: keys/AMS/${GIT_USER}! Deleting..."
    rd keys delete -p "keys/AMS/${GIT_USER}"
  fi
}

function configure {
  ${CMDS} -p $x -- \
  --resources.source.1.config.format=resourcexml \
  --resources.source.1.config.file=/var/lib/rundeck/projects/$x/etc/resources.xml \
  --resources.source.1.config.generateFileAutomatically=true \
  --resources.source.1.type=file \
  --project.name=$x \
  --project.description=$x \
  --project.ssh-command-timeout=0 \
  --project.nodeCache.delay=30 \
  --service.FileCopier.default.provider=jsch-scp \
  --service.NodeExecutor.default.provider=jsch-ssh \
  --project.ssh-connect-timeout=0 \
  --project.ssh-authentication=privateKey \
  --project.disable.schedule=false \
  --project.jobs.gui.groupExpandLevel=0 \
  --project.disable.executions=false \
  --project.ssh-keypath=/var/lib/rundeck/.ssh/id_rsa \
  --project.nodeCache.enabled=true

  if [[ $x == blah1 || $x = blah2 ]]; then
    rd projects configure update -p $x -- \
    --resources.source.1.config.format=resourcexml \
    --resources.source.1.config.file=/var/lib/rundeck/projects/$x/etc/rancher.resources.xml \
    --resources.source.1.config.generateFileAutomatically=true \
    --resources.source.1.type=file
  fi
}

function configure_scm {
  if rd keys list -p "keys/AMS" 2> /dev/null | grep -F "keys/AMS/${GIT_USER}" > /dev/null; then
    echo "Resource already exists: keys/AMS/${GIT_USER}!"
    rd keys delete -p "keys/AMS/${GIT_USER}"
  fi
  echo ${GIT_PASSWORD} > /tmp/$$.txt
  echo "Resource created: keys/AMS/${GIT_USER}"
  rd keys create -p "keys/AMS/${GIT_USER}" -t password -f /tmp/$$.txt
  rm /tmp/$$.txt

  for x in ${GIT_PROJECTS}; do
    echo "Configuring SCM for: $x"
cat > $x.json <<-EOF
{
    "config": {
        "dir": "/var/lib/rundeck/projects/$x/scm",
        "url": "http://${GIT_USER}@${GIT_URL}/${GIT_NAMESPACE}/$x.git",
        "_useFilePattern": "true",
        "fetchAutomatically": "false",
        "filePattern": ".*\.yaml",
        "importUuidBehavior": "remove",
        "exportUuidBehavior": "remove",
        "useFilePattern": "true",
        "committerName": "AMS",
        "committerEmail": "root@rootrulez.com",
        "pathTemplate": "\${job.group}\${job.name}.\${config.format}",
        "format": "yaml",
        "branch": "${GIT_BRANCH}",
        "strictHostKeyChecking": "no",
        "gitPasswordPath": "keys/AMS/${GIT_USER}",
        "enabled": "true",
    }
}
EOF

    rd projects scm setup -t git-import -i import -p $x -f $x.json
    rd projects scm setup -t git-export -i export -p $x -f $x.json
    rm -f $x.json
    rd projects scm perform -p $x -i import --action initialize-tracking -f useFilePattern="true" filePattern=".*\\.yaml"
    rd projects scm perform -i import -p $x -a import-all -A
  done
}

##### Error handling
: "${GIT_USER?Need to set GIT_USER}"
: "${GIT_PASSWORD?Need to set GIT_PASSWORD}"
: "${GIT_BRANCH?Need to set GIT_BRANCH}"
: "${GIT_TOKEN?Need to set GIT_TOKEN}"
: "${RD_URL?Need to set RD_URL}"
: "${RD_TOKEN?Need to set RD_URL}"
: "${GIT_PROJECTS:?Need to set GIT_PROJECTS non-empty}"

rd system info > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  rd system info
  echo "Rundeck CLI werkt niet."
  exit 1
fi


##### Posistional params
[[ $# -eq 0 ]] && usage

while [ $# -gt 0 ]; do
    case $1 in
      --delete )       shift && DELETE="true" ;;
      --configure )    shift && CONFIGURE="true" ;;
      --debug )        DEBUG=debug ;;
      -? | --help )    usage && exit 0 ;;
      * )              echo -e "\nError: Unknown option: $1\n" >&2 && exit 1 ;;
    esac
    shift
done

if [[ ! -z ${DEBUG} ]]; then set -x; fi


### Delete projects
if [[ ! -z ${DELETE} ]]; then delete && exit 0; fi


### Create projects
if [ ! -z ${CONFIGURE} ]; then
  for x in ${GIT_PROJECTS}; do
    if rd projects list --outformat "%name" | grep -Fxq $x; then
      echo "Project $x already exists. Continuuing to configure..."
      CMDS="rd projects configure update"
      configure
    else
      echo "Project $x doesn't exist. Creating..."
      CMDS="rd projects create"
      configure
    fi
  done
  configure_scm
fi

