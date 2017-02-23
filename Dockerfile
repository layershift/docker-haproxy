FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum install -y haproxy socat iptables

RUN yum install -y supervisor
RUN yum clean all

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./etc/supervisord.conf /etc/supervisord.conf
COPY ./etc/supervisord.d/haproxy-alert.ini /etc/supervisord.d/haproxy-alert.ini
COPY ./alert.py /root/alert.py
COPY ./etc/iptables /etc/sysconfig/iptables

RUN /bin/systemctl enable supervisord && \
    /bin/systemctl enable haproxy

VOLUME [ "/etc/haproxy", "/etc/supervisord.d", "/root" ]

EXPOSE 3306 9000 80

