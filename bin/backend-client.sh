#!/usr/bin/env bash

client_project_hash_file=${HOME}/.hash-files/client.hash
backend_project_hash_file=${HOME}/.hash-files/backend.hash

# create hash file in case the file does not exist
( [ -e "$client_project_hash_file" ] || touch "$client_project_hash_file" ) && [ ! -w "$client_project_hash_file" ] && echo cannot write to ${client_project_hash_file} && exit 1

( [ -e "$backend_project_hash_file" ] || touch "$backend_project_hash_file" ) && [ ! -w "$backend_project_hash_file" ] && echo cannot write to ${backend_project_hash_file} && exit 1

if [ -z "${CIRCLE_PR_NUMBER}" ] ; then

  echo "CLIENT PROJECT HASH CHECK"
  client_hash=$(<${client_project_hash_file})
  new_client_hash=$(git log -n1 --oneline ${CLIENT_PROJECT} | awk '{print $1;}')

  # build client if necessary
  if [ "$client_hash" != "$new_client_hash" ]; then
    echo "New hash = ${new_client_hash}, old hash = ${client_hash}"
    echo ${new_client_hash} > ${client_project_hash_file}
    cd ${CLIENT_PROJECT}/ && \
             npm install && \
             npm install -g code-push-cli && \
             code-push login --accessKey ${CODE_PUSH_ACCESS_KEY} && \
             code-push release-react ${CLIENT_APP_NAME} android -d "Staging" --dev false
    cd -
    cd ${CLIENT_PROJECT}/android/ && \
          ./gradlew dependencies && \
          ./gradlew assembleInternalRelease assembleProductionRelease crashlyticsUploadDistributionInternalRelease crashlyticsUploadDistributionProductionRelease && \
          cd -
  fi

  echo "BACKEND PROJECT HASH CHECK"
  backend_hash=$(<${backend_project_hash_file})
  new_backend_hash=$(git log -n1 --oneline ${BACKEND_PROJECT} | awk '{print $1;}')

  # build backend if necessary
  if [ "$backend_hash" != "$new_backend_hash" ]; then
    echo "New hash = ${new_backend_hash}, old hash = ${backend_hash}"
    echo ${new_backend_hash} > ${backend_project_hash_file}
    mvn clean install -U -f ${BACKEND_PROJECT} -Dfat
  fi

fi
