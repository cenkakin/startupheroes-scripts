#!/usr/bin/env bash

curl -X POST --header "Content-Type: application/json" -d '{
  "build_parameters": {
      "PR_NUMBER" : "'${CI_PULL_REQUEST##*/}'",
      "BRANCH":"'${CIRCLE_BRANCH}'",
      "REPOSITORY":"'${CIRCLE_PROJECT_USERNAME}'/'${CIRCLE_PROJECT_REPONAME}'"
  }
}
' "https://circleci.com/api/v1.1/project/github/${SONAR_SCANNER_REPOSITORY}?circle-token=${CIRCLE_TOKEN}"
