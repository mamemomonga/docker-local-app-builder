#!/bin/bash
set -eux
source config
exec docker build \
	--build-arg="NODEJS_VERSION=$NODEJS_VERSION" \
	--build-arg="MISSKEY_VERSION=$MISSKEY_VERSION" \
	-t $IMAGE_NAME .
