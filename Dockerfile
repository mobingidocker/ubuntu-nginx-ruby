FROM ubuntu:14.04
MAINTAINER david.siaw@mobingi.com

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get update
RUN apt-get install -y supervisor git
RUN mkdir -p /var/log/supervisor

RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd

RUN apt-get install -y curl
RUN command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -L get.rvm.io | bash -s stable --rails

ENV RUBY_VERSION 2.1.0
ENV RAILS_VERSION 4.0.0
ENV PASSENGER_VERSION 4.0.37

RUN echo 'source /usr/local/rvm/scripts/rvm' >> /etc/bash.bashrc
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install $RUBY_VERSION && rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems current'

RUN apt-get install -y libcurl4-openssl-dev

RUN /bin/bash -l -c 'gem install passenger --version $PASSENGER_VERSION'
RUN /bin/bash -l -c 'passenger-install-nginx-module --auto-download --auto --prefix=/opt/nginx'

RUN /bin/bash -l -c 'gem install bundler'
RUN /bin/bash -l -c 'gem install rails --version=$RAILS_VERSION'

RUN apt-get install -y nodejs

# nginx config
RUN mkdir -p /var/log/nginx/
ADD nginx.conf /opt/nginx/conf/nginx.conf

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config /config
COPY sudoers /etc/sudoers

COPY Gemfile /root/bootstrapgems/Gemfile

ADD run.sh /run.sh
RUN chmod 755 /*.sh

EXPOSE 22 80
CMD ["/run.sh"]
