# HAProxy for MariaDB Galera Cluster

Made for [Layershift Jelastic PaaS](https://www.layershift.com/jelastic).

## About

HAProxy in this installation is set up to serve as proxy between Galera Cluster and your application.

The main configuration is located in [/etc/haproxy/haproxy.cfg](https://github.com/bubbl/docker-haproxy/blob/master/haproxy.cfg) file.

The installation comes bundled with a simple [monitor script](https://github.com/bubbl/docker-haproxy/blob/master/alert.py) running under [supervisord](https://github.com/bubbl/docker-haproxy/blob/master/etc/supervisord.conf).

