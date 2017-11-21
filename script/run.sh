#!/bin/bash

exec > >(tee /var/log/startup.log) 2>&1

echo "installing" > /var/log/container_status

echo "Ruby Version:"
ruby -v

echo "Running init script"
bash /tmp/init/init.sh

echo "Create Rails Directory"
mkdir -p /srv/rails
cp -r /srv/code /srv/rails/app
chown -R www-data:www-data /srv/rails/app/public
cd /srv/rails/app
mkdir -p tmp
chown -R www-data:www-data /srv/rails/app/tmp
chmod -R 777 /srv/rails/app/tmp

echo "Prepare logging directory"
rm -rf /srv/rails/app/log
mkdir -p /var/log/rails
ln -s /var/log/rails/ /srv/rails/app/log

echo "Prepare production log"
touch log/production.log
chmod 666 log/production.log
chown -R www-data:www-data /srv/rails/app/log/

echo "Running bundler..."
bundle install --deployment -j4 --without development:test

echo "Migrate database"
bundle exec rake db:migrate RAILS_ENV="production"
bundle exec rake assets:precompile RAILS_ENV="production"

echo "complete" > /var/log/container_status

mkdir /var/log/supervisor

exec /usr/bin/supervisord
