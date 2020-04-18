FROM ubuntu:18.04
MAINTAINER TAKANO Mitsuhiro
# @takano32 <takano32@gmail.com>

RUN apt-get update && \
    apt-get install -y \
      make \
      wget \
      jq \
      nginx \
      fcgiwrap \
      squid \
      redis-tools \
      && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY config/nginx_config /etc/nginx/sites-available/vscovid-crawler.conf
RUN ln -s /etc/nginx/sites-available/vscovid-crawler.conf /etc/nginx/sites-enabled/vscovid-crawler.conf

COPY config/squid.conf /etc/squid/squid.conf

WORKDIR /app
COPY . /app

COPY docker-entrypoint.sh /usr/local/sbin/docker-entrypoint.sh
ENTRYPOINT [ "docker-entrypoint.sh" ]

COPY docker/crawler/bin /usr/local/bin
EXPOSE 80