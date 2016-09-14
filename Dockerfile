FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum update -y && \
    yum install -y gcc pcre-static pcre-devel

WORKDIR /tmp

RUN wget http://www.haproxy.org/download/1.6/src/haproxy-1.6.9.tar.gz && \
    tar xzvf haproxy-1.6.9.tar.gz && \
    cd haproxy-1.6.9 && \
    make TARGET=linux2628 && \
    make install && \
    mkdir -p /etc/haproxy && \
    mkdir -p /run/haproxy && \
    mkdir -p /var/lib/haproxy && \
    touch /var/lib/haproxy/stats && \
    useradd -r haproxy && \
    chown -R haproxy: /var/lib/haproxy/

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./start.sh /

CMD [ "/start.sh" ]
