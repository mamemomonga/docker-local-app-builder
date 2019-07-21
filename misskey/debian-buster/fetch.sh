#!/bin/bash
set -eux
source config
docker pull $IMAGE_NAME

mkdir -p var
exec docker run --rm $IMAGE_NAME cat "/$APP_NAME.tar" > var/$APP_NAME-$MISSKEY_VERSION-$OS-$ARCH.tar

