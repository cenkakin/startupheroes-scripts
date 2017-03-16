#!/usr/bin/env bash

npm install
npm install -g code-push-cli
code-push login --accessKey ${CODE_PUSH_ACCESS_KEY}
code-push release-react ${CODE_PUSH_REPO_NAME} android -d "Staging" --dev false
cd android
./gradlew dependencies
./gradlew assembleInternalRelease assembleProductionRelease crashlyticsUploadDistributionInternalRelease crashlyticsUploadDistributionProductionRelease
cd ..

