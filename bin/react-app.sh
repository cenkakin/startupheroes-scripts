#!/usr/bin/env bash

npm install
npm install -g code-push-cli
code-push login --accessKey ${CODE_PUSH_ACCESS_KEY}
code-push release-react ${CODE_PUSH_REPO_NAME} android -d "Staging" --dev false
cd android
./gradlew dependencies
./gradlew assembleInternalRelease crashlyticsUploadDistributionInternalRelease
./gradlew assembleProductionRelease crashlyticsUploadDistributionProductionRelease
cd ..
mkdir /tmp/bugsnag
node node_modules/react-native/local-cli/cli.js bundle \
--platform android \
--dev false \
--entry-file index.android.js \
--bundle-output /tmp/bugsnag/index.android.bundle \
--sourcemap-output /tmp/bugsnag/index.android.map
find android/app/build/outputs/apk/collectify-*-release.apk | awk -F '-' '{print $3}' | while read line; do
	curl https://upload.bugsnag.com/ \
	-F apiKey=${BUGSNAG_API_KEY} \
	-F appVersion=$line \
	-F minifiedUrl="index.android.bundle" \
	-F sourceMap=@/tmp/bugsnag/index.android.map \
	-F minifiedFile=@/tmp/bugsnag/index.android.bundle \
	-F overwrite=true
	echo
done
