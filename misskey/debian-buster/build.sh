#!/bin/bash
set -eux
source config
exec docker build -t $IMAGE_NAME .
