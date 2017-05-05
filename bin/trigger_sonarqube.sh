#!/usr/bin/env bash

curl -X POST --header "Content-Type: application/json" -d '{
  "build_parameters": {
      "text" : "'${CI_PULL_REQUEST##*/}' '${CIRCLE_PROJECT_USERNAME}'/'${CIRCLE_PROJECT_REPONAME}' '${CIRCLE_BRANCH}'"
  }
}
' "https://circleci.com/api/v1.1/project/github/${SONAR_SCANNER_REPOSITORY}?circle-token=${CIRCLE_TOKEN}"
