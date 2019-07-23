FROM debian:buster as build-dep

RUN set -xe && \
	rm -f /etc/localtime && \
	ln -s /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
	echo 'Asia/Tokyo' > /etc/timezone

RUN set -xe && \
	export DEBIAN_FRONTEND=noninteractive && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		curl git-core ca-certificates gnupg \
		build-essential autoconf automake \
		imagemagick ffmpeg libpq-dev libxml2-dev libxslt1-dev file \
		g++ libprotobuf-dev protobuf-compiler pkg-config gcc autoconf \
		bison libssl-dev libyaml-dev libreadline6-dev \
		zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev \
		libidn11-dev libicu-dev libjemalloc-dev && \
	rm -rf /var/lib/apt/lists/*

RUN set -xe && \
	useradd -m -s /bin/bash mastodon

COPY --chown=mastodon:mastodon prerun /home/mastodon/.prerun
USER mastodon
RUN set -xe && \
	mkdir $HOME/.path && \
	echo "$PATH" > $HOME/.path/00default

# ruby
FROM build-dep as ruby
ARG RUBY_VERSION
RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	curl -o /tmp/ruby.tar.gz https://cache.ruby-lang.org/pub/ruby/2.6/ruby-$RUBY_VERSION.tar.gz && \
	mkdir -p $HOME/ruby && \
	tar zxC $HOME/ruby --strip 1 -f /tmp/ruby.tar.gz && \
	rm /tmp/ruby.tar.gz

RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	cd ruby && \
	./configure --prefix=$HOME/.ruby --with-jemalloc --disable-install-doc && \
	make -j$(getconf _NPROCESSORS_ONLN) && \
	make install && \
	cd && \
	rm -rf $HOME/ruby

RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	echo "$HOME/.ruby/bin" >> .path/01ruby

RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	gem update --system && \
	gem install bundler --no-document --force

RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	bundle config --global jobs $(getconf _NPROCESSORS_ONLN)

# nodejs
FROM build-dep as nodejs
ARG NODEJS_VERSION
RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	case "$(uname -m)" in \
		"x86_64" )  NODEJS_ARCH="x64" ;; \
		"armv7l" )  NODEJS_ARCH="armv7l" ;; \
		"aarch64" ) NODEJS_ARCH="arm64" ;; \
	esac && \
	NODEJS_URL="https://nodejs.org/dist/v$NODEJS_VERSION/node-v$NODEJS_VERSION-linux-$NODEJS_ARCH.tar.xz" && \
	mkdir $HOME/.nodejs && \

	curl -o /tmp/nodejs.tar.xz -L -s $NODEJS_URL && \
	tar JxC $HOME/.nodejs --strip 1 -f /tmp/nodejs.tar.xz && \
	rm -f /tmp/nodejs.tar.xz && \
	echo "$HOME/.nodejs/bin:$PATH" > $HOME/.path/02nodejs

RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	curl -o- -L https://yarnpkg.com/install.sh | bash || true && \
	echo "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH" > $HOME/.path/03yarn

FROM build-dep
USER mastodon
COPY --from=ruby   --chown=mastodon:mastodon /home/mastodon/.ruby   /home/mastodon/.ruby
COPY --from=ruby   --chown=mastodon:mastodon /home/mastodon/.bundle /home/mastodon/.bundle
COPY --from=ruby   --chown=mastodon:mastodon /home/mastodon/.path   /home/mastodon/.path
COPY --from=nodejs --chown=mastodon:mastodon /home/mastodon/.nodejs /home/mastodon/.nodejs
COPY --from=nodejs --chown=mastodon:mastodon /home/mastodon/.yarn   /home/mastodon/.yarn
COPY --from=nodejs --chown=mastodon:mastodon /home/mastodon/.path   /home/mastodon/.path
ARG MASTODON_VERSION
RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	git clone https://github.com/tootsuite/mastodon.git live && cd live && \
	git checkout v$MASTODON_VERSION && \
	bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without development test && \
	yarn install --pure-lockfile
RUN set -xe && \
	eval "$(cat $HOME/.prerun)" && cd && \
	export RAILS_ENV="production" && \
	export NODE_ENV="production" && \
	cd /home/mastodon/live && \
	OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile && \
	yarn cache clean
# 
# RUN set -xe && \
# 	cat $HOME/prerun >> $HOME/.bashrc && \
# 	rm -f $HOME/prerun
# 
# USER root
# 
# RUN set -xe && \
# 	tar cC /home/mastodon -f /mastodon.tar .
# 
# FROM busybox
# COPY --from=build-dep /mastodon.tar /mastodon.tar

