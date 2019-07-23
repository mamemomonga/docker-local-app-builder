#!/bin/bash
set -eu

do_web() {
	export RAILS_ENV=production
	export PORT=3000
	cd $BASEDIR/live
	exec bundle exec puma -C config/puma.rb
}

do_sidekiq() {
	export RAILS_ENV=production
	export DB_POOL=25
	export MALLOC_ARENA_MAX=2
	cd $BASEDIR/live
	exec bundle exec sidekiq -c 25
}

do_streaming() {
	export NODE_ENV=production
	export PORT=4000
	export STREAMING_CLUSTER_NUM=1
	cd $BASEDIR/live
	exec node ./streaming
}

do_tootctl() {
	export RAILS_ENV=production
	cd $BASEDIR/live
	exec bin/tootctl $@
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

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "$BASEDIR/.prerun"
COMMANDS="web sidekiq streaming tootctl"
run $@
