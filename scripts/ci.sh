#!/usr/bin/env bash

set -e

appium & # start appium
bundle exec rake
