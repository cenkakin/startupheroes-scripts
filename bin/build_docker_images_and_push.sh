#!/usr/bin/env bash

docker login -e ${DOCKER_EMAIL} -u ${DOCKER_USER} -p ${DOCKER_PASS}

last_commit_hash=$(git rev-parse --short HEAD 2> /dev/null )
echo "**************************************************************************** "
echo "************** Last commit =  ${last_commit_hash} ************************** "
echo "**************************************************************************** "
cd ${APPS_FOLDER}

[[ !  -z  ${SELECTED_APPS} ]] && apps="${SELECTED_APPS[@]}" || apps="*"

for app in ${apps}; do
  if [ -d ${app} ]; then
    echo "**************************************************************************** "
    echo "************** Building ${app} with docker and shade profiles ************** "
    echo "**************************************************************************** "
    docker_image_name=$DOCKER_USER/${app}

    echo "***************************************************************************** "
    echo "************** Building docker image with name = ${docker_image_name} ************** "
    echo "***************************************************************************** "
    docker build -t ${docker_image_name}:${last_commit_hash} ${app}/target/docker
    docker tag ${docker_image_name}:${last_commit_hash} ${docker_image_name}:latest

    echo "***********************************************************************"
    echo "************** Pushing docker image ${docker_image_name} **************"
    echo "***********************************************************************"
    docker push ${docker_image_name}
   
    echo "***********************************************************************"
    echo "************** Deploying docker image ${docker_image_name} **************"
    echo "***********************************************************************"   
    if ! [ "$(command -v kubectl)" ]; then
      kubectl patch deployment ${app} -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend-container","image":"'$docker_image_name':'$last_commit_hash'"}]}}}}' -n=test
    fi
  fi
done
