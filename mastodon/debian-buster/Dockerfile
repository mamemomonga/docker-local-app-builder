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

USER mastodon

RUN set -xe && \
	echo "$PATH" > $HOME/path && \
	echo 'export PATH="$(cat $HOME/path)"' > $HOME/prerun

ARG NODEJS_VERSION
RUN set -xe && \
	eval "$(cat $HOME/prerun)" && cd && \
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
	echo "$HOME/.nodejs/bin:$PATH" > $HOME/path && \

	export PATH="$(cat $HOME/path)" && \
	cp $HOME/.bashrc $HOME/.bashrc.bak && \
	curl -o- -L https://yarnpkg.com/install.sh | bash || true && \
	cp $HOME/.bashrc.bak $HOME/.bashrc && rm -f $HOME/.bashrc.bak && \
	echo "$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH" > $HOME/path

ARG RUBY_VERSION
RUN set -xe && \
	eval "$(cat $HOME/prerun)" && cd && \
	git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
	cd ~/.rbenv && src/configure && make -C src && \
	echo "$HOME/.rbenv/bin:$PATH" > $HOME/path && \
	echo 'eval "$(rbenv init -)"' >> $HOME/prerun

RUN set -xe && \
	eval "$(cat $HOME/prerun)" && cd && \
	git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
	RUBY_CONFIGURE_OPTS=--with-jemalloc rbenv install $RUBY_VERSION && \
	rbenv global $RUBY_VERSION && \
	gem update --system && \
	gem install bundler --no-document --force

ARG MASTODON_VERSION
RUN set -xe && \
	eval "$(cat $HOME/prerun)" && cd && \
	git clone https://github.com/tootsuite/mastodon.git live && cd live && \
	git checkout v$MASTODON_VERSION && \
	bundle install -j$(getconf _NPROCESSORS_ONLN) --deployment --without development test && \
	yarn install --pure-lockfile

RUN set -xe && \
	eval "$(cat $HOME/prerun)" && cd && \
	export RAILS_ENV="production" && \
	export NODE_ENV="production" && \
	cd /home/mastodon/live && \
	OTP_SECRET=precompile_placeholder SECRET_KEY_BASE=precompile_placeholder bundle exec rails assets:precompile && \
	yarn cache clean

RUN set -xe && \
	cat $HOME/prerun >> $HOME/.bashrc && \
	rm -f $HOME/prerun

USER root

RUN set -xe && \
	tar cC /home/mastodon -f /mastodon.tar .

FROM busybox
COPY --from=build-dep /mastodon.tar /mastodon.tar

