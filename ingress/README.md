# 1. Building Ingress controllers on your cluster
* Run the below commands to create nginx-controller on your cluster and corresponding yaml files are available in the repository 

```
kubectl create -f base/ns-and-sa.yaml
kubectl create -f base/default-server-secret.yaml
kubectl create -f base/nginx-config.yaml
kubectl create -f base/rbac.yaml
kubectl create -f base/daemon-set/nginx-ingress.yaml
```

# 2. Creating HAProxy
* This can be your LoadBalancer on your physical network
* Since its our lab, we can have Linux HAProxy for this exercise
* You can create a new VM in the same network or install haproxy on any of your kubernetes VM's
* I have done this practise on kube-master.lab.net
* Install haproxy on your kube-master.lab.net ` # yum install -y haproxy`
* /etc/haproxy/haproxy.cfg as follows
```
[root@kube-master ingress]# cat /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000



############## Created for my lab practise ################

frontend http_front
  bind *:80
  stats uri /haproxy?stats
  default_backend http_back

backend http_back
  balance roundrobin
  server kube kube-worker-1.lab.net:80
  server kube kube-worker-2.lab.net:80
[root@kube-master ingress]#
```
* Restart and enable haproxy service
```
# systemctl start haproxy
# systemctl status haproxy
# systemctl enable haproxy
```
