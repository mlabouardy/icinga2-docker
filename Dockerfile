FROM ubuntu:16.10
MAINTAINER mlabouardy <mohamed@labouardy.com>

RUN apt-get update && apt install -y software-properties-common && \
    add-apt-repository ppa:formorer/icinga && \
    apt-get update && \
    apt-get install -y icinga2 libnet-dns-perl libnet-snmp-perl mysql-client

RUN service icinga2 start

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y --no-install-recommends nagios-plugins icinga2-ido-mysql
RUN icinga2 api setup
RUN icinga2 feature enable ido-mysql command api

RUN apt-get update && apt-get install -y php5.6

RUN apt-get install -y icingaweb2

RUN addgroup --system icingaweb2
RUN usermod -a -G icingaweb2 www-data
RUN icingacli setup config directory --group icingaweb2
RUN icingacli setup token create

EXPOSE 80 443 5665

#RUN icinga2 api setup

RUN sed -i 's/;date.timezone =/date.timezone = \"Europe\/Paris\"/g' /etc/php/7.0/apache2/php.ini

RUN mkdir -p /etc/icinga2/conf.d/configurations
COPY plugins /etc/icinga2/plugins
COPY icinga2 /etc/icinga2
COPY icingaweb2 /etc/icingaweb2
COPY run.sh /
RUN chmod +x /run.sh

VOLUME ["/etc/icinga2/conf.d/configurations"]

CMD ["/run.sh"]
