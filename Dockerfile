FROM ubuntu:14.04
MAINTAINER david.siaw@mobingi.com

ENV RUBY_VERSION 2.1.0
ENV RAILS_VERSION 4.0.0
ENV PASSENGER_VERSION 4.0.37

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

ADD provision.sh /provision.sh

RUN bash /provision.sh

# nginx config
RUN ln -s /opt/nginx/logs /var/log/nginx

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY config /config
COPY sudoers /etc/sudoers

COPY Gemfile /root/bootstrapgems/Gemfile

ADD run.sh /run.sh
ADD startup.sh /startup.sh
RUN chmod 755 /*.sh

EXPOSE 22 80
CMD ["/run.sh"]
