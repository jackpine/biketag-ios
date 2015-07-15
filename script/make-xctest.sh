#!/usr/bin/env bash

bundle

xcrun xcodebuild \
  clean \
  test \
  -SYMROOT=build \
  -derivedDataPath build \
  -project src/BikeTag.xcodeproj \
  -scheme XCTest \
  -destination 'platform=iOS Simulator,name=iPhone 5s,OS=latest' \
  -sdk iphonesimulator \
  -configuration Debug \
  | bundle exec xcpretty -tc && exit ${PIPESTATUS[0]}
