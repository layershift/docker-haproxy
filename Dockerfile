FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum install -y haproxy socat iptables

RUN yum install -y supervisor
RUN yum clean all

RUN systemctl enable supervisor && \
    systemctl enable haproxy

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./etc/supervisord.conf /etc/supervisord.conf
COPY ./etc/supervisord.d/haproxy-alert.ini /etc/supervisord.d/haproxy-alert.ini
COPY ./alert.py /root/alert.py

RUN iptables -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 9000 && \
    iptables-save > /etc/sysconfig/iptables

VOLUME [ "/etc/haproxy", "/etc/supervisord.conf", "/etc/supervisord.d", "/root" ]

EXPOSE 3306 9000 80

