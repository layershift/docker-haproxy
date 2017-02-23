FROM bbania/centos:base
MAINTAINER "Bart Bania" <contact@bartbania.com>

RUN yum update -y && \
    yum install -y haproxy socat iptables

RUN yum install -y supervisor

RUN systemctl enable supervisord haproxy iptables

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./usr/bin/clustercheck /usr/bin/clustercheck
COPY ./etc/xinetd.d/mysqlchk /etc/xinetd.d/mysqlchk
COPY ./etc/supervisord.conf /etc/supervisord.conf
COPY ./etc/supervisord.d/haproxy-alert.ini /etc/supervisord.d/haproxy-alert.ini

RUN chmod +x /usr/bin/clustercheck
RUN iptables -A PREROUTING -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 9000 && \
    iptables-save > /etc/sysconfig/iptables

EXPOSE 3306 9000 80

