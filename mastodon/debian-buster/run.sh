#!/bin/bash
set -eu
BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $BASEDIR/config

COMMANDS="build push pull fetch setup"

do_build() {
	exec docker build \
		--build-arg="NODEJS_VERSION=$NODEJS_VERSION" \
		--build-arg="RUBY_VERSION=$RUBY_VERSION" \
		--build-arg="MASTODON_VERSION=$MASTODON_VERSION" \
		-t $IMAGE_NAME .
}

do_push() {
	exec docker push $IMAGE_NAME
}

do_pull() {
	exec docker pull $IMAGE_NAME
}

do_fetch() {
	exec docker run --rm $IMAGE_NAME cat "/$APP_NAME.tar" > var/$APP_NAME-$MASTODON_VERSION-$OS-$ARCH.tar
}

do_setup() {
	local dest="${1:-}"
	if [ -z "$dest" ]; then
		echo "USAGE: setup user@host"
		exit 1
	fi
	exec docker run --rm $IMAGE_NAME cat "/$APP_NAME.tar" | ssh $dest tar xvpC /home/mastodon
}

run() {
    for i in $COMMANDS; do
    if [ "$i" == "${1:-}" ]; then
        shift
        do_$i $@
        exit 0
    fi
    done
    echo "USAGE: $( basename $0 ) COMMAND"
    echo "COMMANDS:"
    for i in $COMMANDS; do
    echo "   $i"
    done
    exit 1
}

run $@
