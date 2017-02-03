#!/usr/bin/env bash

docker login -e ${DOCKER_EMAIL} -u ${DOCKER_USER} -p ${DOCKER_PASS}

echo "****************************************************************************"
echo "************** Last commit =  ${CIRCLE_SHA1} **************************"
echo "****************************************************************************"
cd ${APPS_FOLDER}

[[ !  -z  ${SELECTED_APPS} ]] && apps="${SELECTED_APPS[@]}" || apps="*"

for app in ${apps}; do
  if [ -d ${app} ]; then
    docker_image_name=$DOCKER_USER/${app}

    echo "****************************************************************************"
    echo "************** Building docker image with name = ${docker_image_name} ******"
    echo "****************************************************************************"
    docker build -t ${docker_image_name}:${CIRCLE_SHA1} ${app}/target/docker
    docker tag ${docker_image_name}:${CIRCLE_SHA1} ${docker_image_name}:latest

    echo "****************************************************************************"
    echo "************** Pushing docker image ${docker_image_name} *******************"
    echo "****************************************************************************"
    docker push ${docker_image_name}

    if hash kubectl 2>/dev/null; then
        echo "****************************************************************************"
        echo "************** Deploying docker image ${docker_image_name} *****************"
        echo "****************************************************************************"
        kubectl patch deployment ${app} -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend-container","image":"'$docker_image_name':'$last_commit_hash'"}]}}}}' -n=test
    fi
  fi
done
