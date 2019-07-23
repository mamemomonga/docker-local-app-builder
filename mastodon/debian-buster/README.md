# mastodon

## container build

	$ ./run.sh build

## push to DockerHub

	$ ./run.sh push

## pull from DockerHub

	$ ./run.sh pull

## fetch tarfile

	$ ./run.sh fetch

## install /home/mastodon

	$ ./run.sh install target

## uninstall /home/mastodon

	$ ./run.sh uninstall target

## bash shell

	$ ./run.sh bash


# USAGE

	[root@target] sudo useradd -m -s /bin/bash mastodon
	[root@target] sudo su - mastodon
	[mastodon@target] mkdir -m 0700 -p ~/.ssh
	[mastodon@target] echo "ssh-ed25519 .." > ~/.ssh/authorized_keys
	[mastodon@target] chmod 0600  ~/.ssh/authorized_keys

	[host] ./run.sh build
	[host] ./run.sh install mastodon@target

	[mastodon@target] vim ~/.env.production
	[mastodon@target] cd live
	[mastodon@target] ln -s ../.env.production

## Running Test

	[mastodon@target] cd
	[mastodon@target] ./mastodon.sh web
	[mastodon@target] ./mastodon.sh streaming
	[mastodon@target] ./mastodon.sh sidekiq

## Install service

	[root@target] cat > /etc/systemd/system/mastodon-web.service << 'EOS'
	[Unit]
	Description=mastodon-web
	After=network.target
	
	[Service]
	Type=simple
	User=mastodon
	WorkingDirectory=/home/mastodon
	ExecStart=/home/mastodon/mastodon.sh web
	ExecReload=/bin/kill -SIGUSR1 $MAINPID
	TimeoutSec=15
	Restart=always
	
	[Install]
	WantedBy=multi-user.target
	EOS

	[root@target] cat > /etc/systemd/system/mastodon-sidekiq.service << 'EOS'
	[Unit]
	Description=mastodon-sidekiq
	After=network.target
	
	[Service]
	Type=simple
	User=mastodon
	WorkingDirectory=/home/mastodon
	ExecStart=/home/mastodon/mastodon.sh sidekiq
	TimeoutSec=15
	Restart=always
	
	[Install]
	WantedBy=multi-user.target
	EOS

	[root@target] cat > /etc/systemd/system/mastodon-streaming.service << 'EOS'
	[Unit]
	Description=mastodon-streaming
	After=network.target
	
	[Service]
	Type=simple
	User=mastodon
	WorkingDirectory=/home/mastodon
	ExecStart=/home/mastodon/mastodon.sh streaming
	TimeoutSec=15
	Restart=always
	
	[Install]
	WantedBy=multi-user.target
	EOS

	[root@target] systemctl daemon-reload
	[root@target] for i in web sidekiq streaming; do systemctl enable $i; systemctl start $i; systemctl status $i; done
