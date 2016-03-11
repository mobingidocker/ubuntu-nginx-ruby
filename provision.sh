#!/bin/bash
mkdir -p /root/build
cd /root/build

apt-get update
apt-get install -y wget supervisor git zlib1g-dev libmysqlclient-dev libpq-dev nodejs libcurl4-openssl-dev libsqlite3-dev build-essential

mkdir -p /var/log/supervisor

wget -O ruby-install-0.5.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.5.0.tar.gz
tar -xzf ruby-install-0.5.0.tar.gz
pushd ruby-install-0.5.0/ 
	make install
popd
/usr/local/bin/ruby-install --system ruby 2.1.0 -- --disable-install-rdoc
export PATH=$PATH:/usr/local/bin
which ruby

wget https://rubygems.org/rubygems/rubygems-2.5.1.tgz
tar xvzf rubygems-2.5.1.tgz
pushd rubygems-2.5.1 
	ruby setup.rb config
	ruby setup.rb setup
	ruby setup.rb install
popd

gem install passenger 
passenger-install-nginx-module

mkdir -p /var/log/nginx/
rm -rf /opt/nginx/logs
ln -s /var/log/nginx /opt/nginx/logs

ruby /configure_nginx.rb
echo daemon off\; >> /opt/nginx/conf/nginx.conf

gem install bundler
