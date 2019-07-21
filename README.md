# docker-local-app-builder

* Docker HubやAWSを駆使し、遅いアーキテクチャー向けの重いビルドを高速なマシンでビルドし、Docker Imageとして受信して展開するツールです。
* 現在まともに使えるか確認中です。

## 必要なもの

* すべてLinux
* 動かしたい遅いサーバ
* 遅いサーバと同じアーキテクチャのDockerが動く手元にあるマシン
* 遅いサーバと同じアーキテクチャのめっちゃ速いマシン(GCP GCEやAWS EC2など)
* Docker Hubアカウント

自分用をつくるなら、事前にこのリポジトリをcloneして、configを自分用に設定してください。

## 手順

1. Docker Hubにリポジトリをつくる
2. AWS EC2でめっちゃ早くて動かしたい対象と同じアーキテクチャのマシンを借りる(amd64ならEC2 a1.xlarge Ubuntu Bionicとか)

ここからは時間との勝負、時は金なり

	$ sudo apt update
	$ sudo apt install git
	$ curl https://get.docker.com/ | sudo sh
	$ sudo sh -c 'usermod -aG docker $SUDO_USER'
	$ exit

再ログイン

	$ docker login

自分のDocker Hubのアカウントにログイン

	$ git clone このリポジトリ
	$ cd misskey/debian-buster
	$ ./build.sh
	$ docker push $(source ./config; echo $IMAGE_NAME )
	$ sudo poweroff

インスタンスを Terminateする

3. 同じアーキテクチャでDockerの動くマシンを用意

	$ git clone このリポジトリ
	$ cd misskey/debian-buster
	$ ./fetch.sh

これで misskey.tar が獲得できるので、動かしたいサーバにscpとかで送信し

	$ tar xvpC /home/misskey -f /tmp/misskey.tar

で展開できる。

なお、Dockerfileのbuild-depで使用されているOSと同じものを使用し、aptで導入されているものは同様に導入する必要がある。

