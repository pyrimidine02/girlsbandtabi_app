#!/bin/bash
set -e

flutter pub get
cd ios
pod install --repo-update
