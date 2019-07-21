#!/bin/bash
set -eux
source config
docker pull $IMAGE_NAME
exec docker run --rm $IMAGE_NAME cat "/$APP_NAME.tar" > $APP_NAME.tar

