#!/usr/bin/env bash

TARGET_NAME="BikeTag"
XC_PROJECT="src/BikeTag.xcodeproj"
XC_SCHEME="${TARGET_NAME}"

if [ ! -z "${1}" ]; then
  CONFIG="${1}"
else
  CONFIG=Debug
fi

CAL_DISTRO_DIR="${PWD}/build/ipa"
ARCHIVE_BUNDLE="${CAL_DISTRO_DIR}/${TARGET_NAME}.xcarchive"
APP_BUNDLE_PATH="${ARCHIVE_BUNDLE}/Products/Applications/${TARGET_NAME}.app"
DYSM_PATH="${ARCHIVE_BUNDLE}/dSYMs/${TARGET_NAME}.app.dSYM"
IPA_PATH="${CAL_DISTRO_DIR}/${TARGET_NAME}.ipa"


rm -rf "${CAL_DISTRO_DIR}"
mkdir -p "${CAL_DISTRO_DIR}"

set +o errexit


if [ -z "${CODE_SIGN_IDENTITY}" ]; then
    xcrun xcodebuild archive \
        -SYMROOT="${CAL_DISTRO_DIR}" \
        -derivedDataPath "${CAL_DISTRO_DIR}" \
        -project "${XC_PROJECT}" \
        -scheme "${XC_SCHEME}" \
        -configuration "${CONFIG}" \
        -archivePath "${ARCHIVE_BUNDLE}" \
        ARCHS="armv7 armv7s arm64" \
        VALID_ARCHS="armv7 armv7s arm64" \
        ONLY_ACTIVE_ARCH=NO \
        -sdk iphoneos | xcpretty -c
   else
        xcrun xcodebuild archive \
        CODE_SIGN_IDENTITY="${CODE_SIGN_IDENTITY}" \
        -SYMROOT="${CAL_DISTRO_DIR}" \
        -derivedDataPath "${CAL_DISTRO_DIR}" \
        -project "${XC_PROJECT}" \
        -scheme "${XC_SCHEME}" \
        -configuration "${CONFIG}" \
        -archivePath "${ARCHIVE_BUNDLE}" \
        ARCHS="armv7 armv7s arm64" \
        VALID_ARCHS="armv7 armv7s arm64" \
        ONLY_ACTIVE_ARCH=NO \
        -sdk iphoneos | xcpretty -c
   fi

RETVAL=${PIPESTATUS[0]}

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL:  archive failed"
    exit $RETVAL
fi

set +o errexit


PACKAGE_LOG="${CAL_DISTRO_DIR}/package.log"

xcrun \
  -sdk \
  iphoneos \
  PackageApplication \
  -v "${APP_BUNDLE_PATH}" \
  -o "${IPA_PATH}" > "${PACKAGE_LOG}"

RETVAL=$?

echo "INFO: Package Application Log: ${PACKAGE_LOG}"

set -o errexit

if [ $RETVAL != 0 ]; then
    echo "FAIL:  export archive failed"
    exit $RETVAL
fi

rm -rf "${PWD}/${TARGET_NAME}.ipa"
cp "${IPA_PATH}" "${PWD}/"
echo "Created ${PWD}/${TARGET_NAME}.ipa"

cp -r "${DYSM_PATH}" "${PWD}/"
echo "Created "${PWD}/${TARGET_NAME}.app.dSYM""

exit 0
