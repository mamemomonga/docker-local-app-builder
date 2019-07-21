#!/bin/bash
set -eux
source config
exec docker push $IMAGE_NAME
