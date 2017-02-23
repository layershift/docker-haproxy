FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum update -y && \
    yum install -y haproxy socat && \
    yum install -y supervisord && \
    systemctl enable supervisord
    systemctl enable haproxy

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./usr/bin/clustercheck /usr/bin/clustercheck
COPY ./etc/xinetd.d/mysqlchk /etc/xinetd.d/mysqlchk
COPY ./etc/supervisord.conf /etc/supervisord.conf
COPY ./etc/supervisord.d/haproxy-alert.ini /etc/supervisord.d/haproxy-alert.ini

RUN chmod +x /usr/bin/clustercheck

EXPOSE 3306 9000

