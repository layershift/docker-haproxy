FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum install -y haproxy socat iptables
RUN yum install -y supervisor
RUN yum clean all

RUN mkdir -p /etc/haproxy/{supervisor,scripts}

COPY ./etc/supervisord.service /usr/lib/systemd/system/supervisord.service
COPY ./etc/haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./etc/supervisord.conf /etc/haproxy/supervisor/supervisord.conf
COPY ./etc/supervisord.d/haproxy-alert.ini /etc/haproxy/supervisor/d/haproxy-alert.ini
COPY ./etc/alert.py /etc/haproxy/scripts/
COPY ./etc/iptables /etc/sysconfig/iptables

RUN /bin/systemctl daemon-reload && \
    /bin/systemctl enable supervisord && \
    /bin/systemctl enable haproxy

VOLUME "/etc/haproxy"

EXPOSE 3306 80
