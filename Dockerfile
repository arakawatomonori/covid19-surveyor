FROM ubuntu:18.04
MAINTAINER TAKANO Mitsuhiro
# @takano32 <takano32@gmail.com>

RUN apt-get update

RUN apt-get install -y apt-utils
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get install -y wget nginx squid

ADD nginx_config /etc/nginx/site-available/vscovid-crawler.conf
RUN ln -s /etc/nginx/site-available/vscovid-crawler.conf /etc/nginx/modules-enabled/vscovid-crawler.conf

ADD squid.conf /etc/squid/squid.conf

# RUN apt-get -y install curl
# RUN apt-get -y install screen

EXPOSE 80
CMD ["bash"]

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh
ENTRYPOINT ["/sbin/entrypoint.sh"]

