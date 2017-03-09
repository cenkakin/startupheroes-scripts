#!/usr/bin/env bash

docker login -e ${DOCKER_EMAIL} -u ${DOCKER_USER} -p ${DOCKER_PASS}

last_commit=${CIRCLE_SHA1:0:7}

echo "****************************************************************************"
echo "************** Last commit =  ${last_commit} *******************************"
echo "****************************************************************************"
cd ${APPS_FOLDER}

[[ !  -z  ${SELECTED_APPS} ]] && apps="${SELECTED_APPS[@]}" || apps="*"

for app in ${apps}; do
  if [ -d ${app} ]; then
    docker_image_name=$DOCKER_USER/${app}

    echo "****************************************************************************"
    echo "************** Building docker image with name = ${docker_image_name} ******"
    echo "****************************************************************************"
    docker build -t ${docker_image_name}:${last_commit} ${app}/target/docker
    docker tag ${docker_image_name}:${last_commit} ${docker_image_name}:latest

    echo "****************************************************************************"
    echo "************** Pushing docker image ${docker_image_name} *******************"
    echo "****************************************************************************"
    docker push ${docker_image_name}
  fi
done
