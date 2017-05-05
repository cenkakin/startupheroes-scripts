#!/usr/bin/env bash

hashFile=${HOME}/.asset-hash/asset.hash

# create hash file in case the file does not exist
( [ -e "$hashFile" ] || touch "$hashFile" ) && [ ! -w "$hashFile" ] && echo cannot write to ${hashFile} && exit 1

# hashes
hash=$(<$hashFile)
newHash=$(git log -n1 --oneline ${ASSET_FOLDER} | awk '{print $1;}')

# build assets if necessary
if [ "$hash" != "$newHash" ]; then
  echo "New hash = ${newHash}, old hash = ${hash}"
  echo ${newHash} > $hashFile
  ./mvnw clean install -f ${ASSET_FOLDER}
fi
