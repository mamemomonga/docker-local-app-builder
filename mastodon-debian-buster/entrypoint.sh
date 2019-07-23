#!/bin/bash
set -eu

case "${1:-}" in
	"fetch" )
		exec tar cC /home/mastodon \
			.bundle \
			.cache \
			.nodejs \
			.path \
			.prerun \
			.ruby \
			.yarn \
			live
		;;
	* )
		exec $@
		;;
esac

