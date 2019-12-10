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

# 3. Creating an NGINX WebApp
* Use the yaml files available in the repository 
```
# kubectl create -f nginx-deploy.yaml
[root@kube-master 1.pod]# kubectl get all
NAME                                          READY   STATUS    RESTARTS   AGE
pod/nfs-client-provisioner-6f689974cb-f5wn5   1/1     Running   3          7d21h

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   16d

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nfs-client-provisioner   1/1     1            1           13d

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nfs-client-provisioner-6f689974cb   1         1         1       13d
[root@kube-master 1.pod]# watch kubectl get all
[root@kube-master 1.pod]# kubectl get all
NAME                                          READY   STATUS    RESTARTS   AGE
pod/nfs-client-provisioner-6f689974cb-f5wn5   1/1     Running   3          7d22h
pod/nginx-deploy-65b57cc5b-dqldx              1/1     Running   0          51m

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   16d

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nfs-client-provisioner   1/1     1            1           13d
deployment.apps/nginx-deploy             1/1     1            1           51m

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nfs-client-provisioner-6f689974cb   1         1         1       13d
replicaset.apps/nginx-deploy-65b57cc5b              1         1         1       51m
[root@kube-master 1.pod]#
```
* Publish the nginx deployment, By default it publish the service as "ClusterIP" which will communicate with in the cluster
```
# kubectl expose deploy nginx-deploy --port 80
[root@kube-master 1.pod]# kubectl get svc
NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
kubernetes     ClusterIP   10.96.0.1      <none>        443/TCP   16d
nginx-deploy   ClusterIP   10.98.63.174   <none>        80/TCP    16s
[root@kube-master 1.pod]#
```
# 4. Create the Ingress rule
* Refer the ingress rule file available in the repository to create the rule
```
[root@kube-master ingress]# kubectl create -f ingress-rule-1.yaml
ingress.extensions/ingress-rule-1 created
[root@kube-master ingress]#

```
# 5. Access the Nginx WebApp
* Spoof your haproxy in your windows drivers/etc/hosts file
```
192.168.58.200	kube-master.lab.net		kube-master		km
192.168.58.201	kube-worker-1.lab.net		kube-worker-1	k1
192.168.58.202	kube-worker-2.lab.net		kube-worker-2		k2
192.168.58.203	kube-worker-3.lab.net		kube-worker-3		k3

## To access NGINX WebApp ##
192.168.58.200  nginx.lab.net
```
* Open Web Browser and hit ` http://nginx.lab.net `
![Image of nginx](https://github.com/RamkumarMM/kubernetes/blob/master/images/nginx.jpg)

# 6. Deploying couple of more Nginx WebApp
* You can refer the nginx-blue & nginx-green deploy yaml files available in the repo
```
[root@kube-master ingress]# kubectl create -f nginx-blue-deploy.yaml
deployment.apps/nginx-blue-deploy created
[root@kube-master ingress]# kubectl create -f nginx-green-deploy.yaml
deployment.apps/nginx-green-deploy created
[root@kube-master ingress]#
[root@kube-master 1.pod]# kubectl get po,deploy,rs
NAME                                          READY   STATUS    RESTARTS   AGE
pod/nfs-client-provisioner-6f689974cb-f5wn5   1/1     Running   3          7d23h
pod/nginx-blue-deploy-568464fcf-49wcc         1/1     Running   0          23s
pod/nginx-deploy-65b57cc5b-dqldx              1/1     Running   0          64m
pod/nginx-green-deploy-5fb9c47598-hsr8s       1/1     Running   0          18s

NAME                                     READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nfs-client-provisioner   1/1     1            1           14d
deployment.apps/nginx-blue-deploy        1/1     1            1           23s
deployment.apps/nginx-deploy             1/1     1            1           64m
deployment.apps/nginx-green-deploy       1/1     1            1           18s

NAME                                                DESIRED   CURRENT   READY   AGE
replicaset.apps/nfs-client-provisioner-6f689974cb   1         1         1       14d
replicaset.apps/nginx-blue-deploy-568464fcf         1         1         1       23s
replicaset.apps/nginx-deploy-65b57cc5b              1         1         1       64m
replicaset.apps/nginx-green-deploy-5fb9c47598       1         1         1       18s
[root@kube-master 1.pod]#

```
* Publish the nginx-blue and nginx-green services
```
[root@kube-master ingress]# kubectl expose deploy nginx-blue-deploy --port 80
service/nginx-blue-deploy exposed
[root@kube-master ingress]# kubectl expose deploy nginx-green-deploy --port 80
service/nginx-green-deploy exposed
[root@kube-master ingress]#
[root@kube-master ingress]# kubectl get svc
NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes           ClusterIP   10.96.0.1        <none>        443/TCP   16d
nginx-blue-deploy    ClusterIP   10.97.231.207    <none>        80/TCP    12s
nginx-deploy         ClusterIP   10.98.63.174     <none>        80/TCP    11m
nginx-green-deploy   ClusterIP   10.103.243.123   <none>        80/TCP    7s
[root@kube-master ingress]#
```
# 7. Create the Ingress rules for nginx-blue & nginx-green
* Refer the ingress rule file available in the repository to create the rule
```
[root@kube-master ingress]# kubectl create -f ingress-rule-all.yaml
ingress.extensions/ingress-rule-all created
[root@kube-master ingress]#
[root@kube-master ingress]# kubectl get ing
NAME               HOSTS                                                  ADDRESS   PORTS   AGE
ingress-rule-all   nginx.lab.net,blue.nginx.lab.net,green.nginx.lab.net             80      23s\
[root@kube-master ingress]# kubectl describe ing ingress-rule-all
Name:             ingress-rule-all
Namespace:        default
Address:
Default backend:  default-http-backend:80 (<none>)
Rules:
  Host                 Path  Backends
  ----                 ----  --------
  nginx.lab.net
                          nginx-deploy:80 (10.36.0.4:80)
  blue.nginx.lab.net
                          nginx-blue-deploy:80 (10.44.0.3:80)
  green.nginx.lab.net
                          nginx-green-deploy:80 (10.44.0.4:80)
Annotations:
Events:
  Type    Reason          Age   From                      Message
  ----    ------          ----  ----                      -------
  Normal  AddedOrUpdated  43s   nginx-ingress-controller  Configuration for default/ingress-rule-all was added or updated
  Normal  AddedOrUpdated  43s   nginx-ingress-controller  Configuration for default/ingress-rule-all was added or updated
[root@kube-master ingress]#
[root@kube-master ingress]#
```
 
# 8. Access the Nginx WebApp
* Spoof your haproxy in your windows drivers/etc/hosts file
```
192.168.58.200	kube-master.lab.net		kube-master		km
192.168.58.201	kube-worker-1.lab.net		kube-worker-1	k1
192.168.58.202	kube-worker-2.lab.net		kube-worker-2		k2
192.168.58.203	kube-worker-3.lab.net		kube-worker-3		k3

## To access NGINX WebApp ##
192.168.58.200  nginx.lab.net
192.168.58.200  blue.nginx.lab.net
192.168.58.200  green.nginx.lab.net
```

* Open NGINX WebApp Browser and hit ` http://nginx.lab.net `
![Image of nginx](https://github.com/RamkumarMM/kubernetes/blob/master/images/nginx.jpg)

* Open NGINX Blue WebApp Browser and hit ` http://blue.nginx.lab.net `
![Image of nginx-blue](https://github.com/RamkumarMM/kubernetes/blob/master/images/nginx-blue.jpg)

* Open NGINX Green WebApp Browser and hit ` http://green.nginx.lab.net `
![Image of nginx-green](https://github.com/RamkumarMM/kubernetes/blob/master/images/nginx-green.jpg)
