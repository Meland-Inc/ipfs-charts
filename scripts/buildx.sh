#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

### get project dir
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
readonly PROJECT_ROOT="$(dirname $DIR)"
readonly PROJECT_NAME="ipfs";
readonly DOCKER_NAMESPACE=${DEPLOY_NAMESPACE}
readonly VERSION=${1:-$(git rev-parse --short HEAD)}

get_current_version() {
    echo ${VERSION}
}

get_docker_tag() {
    appname=${1:-""}
    version=${2:-""}
    echo "${DOCKER_NAMESPACE}/${appname}:${version}"
}

echo "building ${PROJECT_NAME} with docker ..."

version=$(get_current_version)
image_name=$(get_docker_tag ${PROJECT_NAME} ${version})

docker build ${PROJECT_ROOT} -f ${PROJECT_ROOT}/docker/Dockerfile -t ${image_name}
docker push ${image_name}