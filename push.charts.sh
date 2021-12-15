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
readonly PROJECT_ROOT="$DIR"
readonly VERSION=${1:-$(git rev-parse --short HEAD)}

projects=$(find "${PROJECT_ROOT}" -type dir -maxdepth 1 | xargs -I {} basename {});
for chart in $(ls $PROJECT_ROOT/charts)
    do
    echo $chart
    if [[ -d "${PROJECT_ROOT}/charts/$chart" ]];
    then
        ls ${PROJECT_ROOT}/charts/$chart
        helm package ${PROJECT_ROOT}/charts/$chart -d "${PROJECT_ROOT}/.chartsp"
    fi;
done

# helm s3 push 
helm repo add melands3 s3://meland-helm-charts/meland
charts=$(find "${PROJECT_ROOT}/.chartsp" -type file -maxdepth 1 | xargs -I {} basename {});
for chart in $charts
do
    helm s3 push --force "${PROJECT_ROOT}/.chartsp/$chart" melands3
done

rm -rf ${PROJECT_ROOT}/.chartsp

echo "done.";