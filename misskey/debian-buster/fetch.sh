#!/bin/bash
set -eux
source config
exec docker run --rm $IMAGE_NAME cat "/$APP_NAME.tar" > $APP_NAME.tar

