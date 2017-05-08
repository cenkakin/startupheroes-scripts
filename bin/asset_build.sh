#!/usr/bin/env bash

version=$(git log -n1 --oneline ${ASSET_FOLDER} | awk '{print $1;}')
file_count=$(find $HOME/.m2/ -name ${ASSET_FOLDER}-${version}.jar | wc -l)

# build assets if necessary
if [[ ${file_count} -eq 0 ]]; then
  echo "Found file count: ${file_count}"
  ./mvnw clean install -f ${ASSET_FOLDER} -Dasset.version=${version}
fi
