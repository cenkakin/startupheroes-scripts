#!/usr/bin/env bash

npm install
npm install -g code-push-cli
code-push login --accessKey ${CODE_PUSH_ACCESS_KEY}
code-push release-react ${CLIENT_APP_NAME} android -d "Staging" --dev false
./android/gradlew dependencies
./android/gradlew assembleInternalRelease assembleProductionRelease crashlyticsUploadDistributionInternalRelease crashlyticsUploadDistributionProductionRelease

