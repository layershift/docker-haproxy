#!/bin/bash

set -e

exec bash -c \
    "exec haproxy -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid -Ds"
