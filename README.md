# HAProxy for MariaDB Galera Cluster

Made for [Layershift Jelastic PaaS](https://www.layershift.com/jelastic).

## About

HAProxy in this installation is set up to serve as proxy between Galera Cluster and your application.

The main configuration is located in [/etc/haproxy/haproxy.cfg](https://github.com/bubbl/docker-haproxy/blob/master/haproxy.cfg) file.

The installation comes bundled with a simple [monitor script](https://github.com/bubbl/docker-haproxy/blob/master/alert.py) running under [supervisord](https://github.com/bubbl/docker-haproxy/blob/master/etc/supervisord.conf).

# Setup

After creating HAPRoxy container, you should do some manual work (autoamated script is coming).

## /etc/haproxy/haproxy.cfg:

* [Line 40](https://github.com/bubbl/docker-haproxy/blob/master/haproxy.cfg#L40):
  * set a strong username:password for HAPRoxy GUI access.

* [Line 44](https://github.com/bubbl/docker-haproxy/blob/master/haproxy.cfg#L44):
  * change HAP_IP to internal IP of the HAProxy node

* [Lines 50-52](https://github.com/bubbl/docker-haproxy/blob/master/haproxy.cfg#L50-L52):
  * change HOST1/2/3 to desired backend names, e.g. Galera member hostnames
  * change HOST1/2/3_IP to internal IPs of Galera member nodes

## /root/alert.py

* [Lines 9-10](https://github.com/bubbl/docker-haproxy/blob/master/alert.py#L9-L10):
  * set user and password for haproxy GUI access (taken from [/etc/haproxy/haproxy.cfg](https://github.com/bubbl/docker-haproxy/blob/master/haproxy.cfg#L40))

* [Line 12](https://github.com/bubbl/docker-haproxy/blob/master/alert.py#L12):
  * set a recognisable string, e.g. blog, main website, for notification subject

Restart services after initial setup:

    systemctl restart haproxy supervisord

## Web GUI

Web GUI is accessible on http://node_hostname/stats

There's a prerouting redirect of port 9000 to 80 in place.


# Galera side

On all Galera member nodes, you have to do the following:

1) Create a file /etc/xinetd.d/mysqlchk with the contents below:

    # default: on
    # description: mysqlchk
    service mysqlchk
    {
            disable = no
            flags = REUSE
            socket_type = stream
            port = 9200
            wait = no
            user = nobody
            server = /usr/bin/clustercheck
            log_on_failure += USERID
            only_from = 0.0.0.0/0
            bind = 0.0.0.0
            per_source = UNLIMITED
    }

2) Downlaod check script from Percona:

    wget -O /usr/bin/clustercheck https://github.com/olafz/percona-clustercheck; chmod +x /usr/bin/clustercheck

3) Adjust iptables to allow HAProxy helath checks

    iptables -I INPUT -s <HAPROXY_IP>/32 -p tcp -m tcp --dport 9200 -j ACCEPT 

4) add mysqlchk to services:

    echo "mysqlchk        9200/tcp                # Galera Clustercheck" >> /etc/services

5) Add HAProxy management users to databases:

    GRANT PROCESS ON *.* TO 'haproxy_root'@'10.10.127.210' IDENTIFIED BY 'o4L4jw4mkimKZXy'; FLUSH PRIVILEGES;
    GRANT PROCESS ON *.* TO 'clustercheckuser'@'localhost' IDENTIFIED BY 'clustercheckpassword!'; FLUSH PRIVILEGES;

6) Restart xinetd:

    systemctl restart xinetd

# TODO

* installation automation

