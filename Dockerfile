FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum update -y && \
    yum install -y haproxy && \
    systemctl enable haproxy

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 3306 9000

