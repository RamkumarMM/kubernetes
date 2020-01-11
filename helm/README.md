# What is Helm?
Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.

Charts are easy to create, version, share, and publish — so start using Helm and stop the copy-and-paste.
https://helm.sh/


# Before you install helm, you workstation should have configured to access kubernetes cluster and kubectl installed on it
* Install kubectl on your workstation
``` 
[root@docker-registry]#  yum install -y kubectl 
```
* Create a local user where you want to perform all your kubernetes activies
``` 
[root@docker-registry]# useradd -d /home/kubeadmin -c "Kubernetes Admin User" -s /bin/bash kubeadmin 
```
* Configure kubenetes cluster on your kubeadmin user
``` 
[kubeadmin@docker-registry ~]$ mkdir .kube 
```
* Copy your kubenetes config on your local users ~/.kube/config
```
[root@kube-master ~]# scp .kube/config  kubeadmin@docker-registry:/home/kubeadmin/.kube/config
kubeadmin@docker-registry's password:
config                                                                                                                                                                      100% 5450     4.7MB/s   00:00
[root@kube-master ~]#
```
* Now try to run kubernetes command to verify you are able to access k8s cluster
```
[kubeadmin@docker-registry ~]$ kubectl get nodes
NAME                    STATUS   ROLES    AGE   VERSION
kube-master.lab.net     Ready    master   48d   v1.16.3
kube-worker-1.lab.net   Ready    <none>   48d   v1.16.3
kube-worker-2.lab.net   Ready    <none>   48d   v1.16.3
[kubeadmin@docker-registry ~]$ kubectl get pods
NAME                                      READY   STATUS    RESTARTS   AGE
nfs-client-provisioner-6f689974cb-t6mkk   1/1     Running   0          14d
[kubeadmin@docker-registry ~]$
```

# Installing Helm on you workstation
```
[root@docker-registry]# mkdir helm
[root@docker-registry]# cd helm
[root@docker-registry helm]# wget https://get.helm.sh/helm-v3.0.2-linux-amd64.tar.gz
[root@docker-registry helm]# tar -zxvf helm-v3.0.2-linux-amd64.tar.gz
[root@docker-registry helm]# cp helm /usr/local/bin
[root@docker-registry linux-amd64]# which helm
/usr/local/bin/helm
[root@docker-registry linux-amd64]#
[root@docker-registry linux-amd64]# helm version
version.BuildInfo{Version:"v3.0.2", GitCommit:"19e47ee3283ae98139d98460de796c1be1e3975f", GitTreeState:"clean", GoVersion:"go1.13.5"}
[root@docker-registry linux-amd64]# helm version --short
v3.0.2+g19e47ee
[root@docker-registry linux-amd64]#
```

* Create tiller service account on your cluster & binding to cluster role
```
[kubeadmin@docker-registry ~]$ kubectl -n kube-system create serviceaccount tiller
serviceaccount/tiller created
[kubeadmin@docker-registry ~]$
[kubeadmin@docker-registry ~]$ kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
clusterrolebinding.rbac.authorization.k8s.io/tiller created
[kubeadmin@docker-registry ~]$ kubectl get clusterrolebinding tiller
NAME     AGE
tiller   7s
[kubeadmin@docker-registry ~]$ 
```



