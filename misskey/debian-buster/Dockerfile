FROM debian:buster as build-dep

RUN set -xe && \
	rm -f /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		python-dev build-essential zlib1g-dev autoconf && \
	rm -rf /var/lib/apt/lists/*

RUN set -xe && \
	find /usr/bin | perl -E '$ct=1; while(<>) { chomp; if (m#python\d\.\d$#) { say "update-alternatives --install /usr/bin/python python $_ $ct"; $ct++}}' | sh -xe && \
	update-alternatives --set python /usr/bin/python2.7

# NODEJSのバージョン
# https://nodejs.org/en/download/current
ENV NODEJS_VERSION=12.6.0

RUN set -xe && \
	useradd -m -s /bin/bash misskey

RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		curl wget git ca-certificates && \
	rm -rf /var/lib/apt/lists/*

USER misskey

RUN set -xe && \
	case "$(uname -m)" in \
		"x86_64" )  NODEJS_ARCH="x64" ;; \
		"armv7l" )  NODEJS_ARCH="armv7l" ;; \
		"aarch64" ) NODEJS_ARCH="arm64" ;; \
	esac && \
	NODEJS_URL="https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-linux-$NODEJS_ARCH.tar.xz" && \
	mkdir /home/misskey/.nodejs && \
	curl -o /tmp/nodejs.tar.xz -L -s $NODEJS_URL && \
	tar JxC /home/misskey/.nodejs --strip 1 -f /tmp/nodejs.tar.xz && \
	rm -f /tmp/nodejs.tar.xz && \
	echo 'export PATH="/home/misskey/.nodejs/bin:$PATH"' >> /home/misskey/.bashrc

ENV PATH=/home/misskey/.nodejs/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# MISSKEYのバージョン
# https://github.com/syuilo/misskey/releases
ENV MISSKEY_VERSION=11.26.1

RUN set -xe && \
	cd /home/misskey && \
	git clone git://github.com/syuilo/misskey.git && \
	cd /home/misskey/misskey && \
	git checkout $MISSKEY_VERSION

RUN set -xe && \
	if [ "$(uname -m)" = "aarch64" ]; then export CPPFLAGS="-DPNG_ARM_NEON_OPT=0"; fi && \
	export NODE_ENV=production && \
	cd /home/misskey/misskey && \
	npm install && \
	npm run build

USER root

RUN set -xe && \
	tar cC /home/misskey -f /misskey.tar .

FROM busybox
COPY --from=build-dep /misskey.tar /misskey.tar

