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

* Adding Helm respoitory 
```
[kubeadmin@docker-registry ~]$ helm repo list
Error: no repositories to show
[kubeadmin@docker-registry ~]$ 

[kubeadmin@docker-registry ~]$ helm repo add stable https://kubernetes-charts.storage.googleapis.com/
"stable" has been added to your repositories
[kubeadmin@docker-registry ~]$

[kubeadmin@docker-registry ~]$ helm repo list
NAME    URL
stable  https://kubernetes-charts.storage.googleapis.com/
[kubeadmin@docker-registry ~]$

```
* Once this is installed, you will be able to list the charts you can install:
```
[kubeadmin@docker-registry ~]$ helm search repo stable
NAME                                    CHART VERSION   APP VERSION             DESCRIPTION
stable/acs-engine-autoscaler            2.2.2           2.1.1                   DEPRECATED Scales worker nodes within agent pools
stable/aerospike                        0.3.2           v4.5.0.5                A Helm chart for Aerospike in Kubernetes
stable/airflow                          5.2.4           1.10.4                  Airflow is a platform to programmatically autho...
stable/ambassador                       5.3.0           0.86.1                  A Helm chart for Datawire Ambassador
stable/anchore-engine                   1.4.0           0.6.0                   Anchore container analysis and policy evaluatio...
stable/apm-server                       2.1.5           7.0.0                   The server receives data from the Elastic APM a...
stable/ark                              4.2.2           0.10.2                  DEPRECATED A Helm chart for ark
stable/artifactory                      7.3.1           6.1.0                   DEPRECATED Universal Repository Manager support...
stable/artifactory-ha                   0.4.1           6.2.0                   DEPRECATED Universal Repository Manager support...
stable/atlantis                         3.10.1          v0.8.2                  A Helm chart for Atlantis https://www.runatlant...
stable/auditbeat                        1.1.0           6.7.0                   A lightweight shipper to audit the activities o...
stable/aws-cluster-autoscaler           0.3.3                                   Scales worker nodes within autoscaling groups.
stable/aws-iam-authenticator            0.1.2           1.0                     A Helm chart for aws-iam-authenticator
stable/bitcoind                         0.2.2           0.17.1                  Bitcoin is an innovative payment network and a ...
stable/bookstack                        1.2.0           0.27.5                  BookStack is a simple, self-hosted, easy-to-use...
stable/buildkite                        0.2.4           3                       DEPRECATED Agent for Buildkite
stable/burrow                           1.5.2           0.29.0                  Burrow is a permissionable smart contract machine
stable/centrifugo                       3.1.1           2.1.0                   Centrifugo is a real-time messaging server.
stable/cerebro                          1.3.1           0.8.5                   A Helm chart for Cerebro - a web admin tool tha...
stable/cert-manager                     v0.6.7          v0.6.2                  A Helm chart for cert-manager
```


* Searching particular chart
```
[kubeadmin@docker-registry ~]$ helm search repo tomcat
NAME            CHART VERSION   APP VERSION     DESCRIPTION
stable/tomcat   0.4.1           7.0             Deploy a basic tomcat application server with s...
[kubeadmin@docker-registry ~]$

[kubeadmin@docker-registry ~]$ helm search repo jenkins
NAME            CHART VERSION   APP VERSION     DESCRIPTION
stable/jenkins  1.9.14          lts             Open source continuous integration server. It s...
[kubeadmin@docker-registry ~]$
```

* Inspect a chart 
```
[kubeadmin@docker-registry ~]$ helm inspect chart stable/jenkins 
apiVersion: v1
appVersion: lts
description: Open source continuous integration server. It supports multiple SCM tools
  including CVS, Subversion and Git. It can execute Apache Ant and Apache Maven-based
  projects as well as arbitrary scripts.
home: https://jenkins.io/
icon: https://wiki.jenkins-ci.org/download/attachments/2916393/logo.png
maintainers:
- email: lachlan.evenson@microsoft.com
  name: lachie83
- email: viglesias@google.com
  name: viglesiasce
- email: maor.friedman@redhat.com
  name: maorfr
- email: mail@torstenwalter.de
  name: torstenwalter
- email: garridomota@gmail.com
  name: mogaal
name: jenkins
sources:
- https://github.com/jenkinsci/jenkins
- https://github.com/jenkinsci/docker-jnlp-slave
- https://github.com/maorfr/kube-tasks
- https://github.com/jenkinsci/configuration-as-code-plugin
version: 1.9.14
[kubeadmin@docker-registry ~]$

[kubeadmin@docker-registry ~]$ helm inspect chart stable/tomcat
apiVersion: v1
appVersion: "7.0"
description: Deploy a basic tomcat application server with sidecar as web archive
  container
home: https://github.com/yahavb
icon: http://tomcat.apache.org/res/images/tomcat.png
maintainers:
- email: ybiran@ananware.systems
  name: yahavb
name: tomcat
version: 0.4.1
[kubeadmin@docker-registry ~]$

```

* Downloading a chart 
```
[kubeadmin@docker-registry ~]$ helm fetch stable/tomcat
[kubeadmin@docker-registry ~]$ ls
tomcat-0.4.1.tgz
[kubeadmin@docker-registry ~]$

[kubeadmin@docker-registry ~]$ ls -lrt tomcat-0.4.1.tgz
-rw-r--r-- 1 kubeadmin kubeadmin 4039 Jan 11 13:36 tomcat-0.4.1.tgz
[kubeadmin@docker-registry ~]$
[kubeadmin@docker-registry ~]$ tar -vf tomcat-0.4.1.tgz
[kubeadmin@docker-registry ~]$
[kubeadmin@docker-registry ~]$ ls
tomcat  tomcat-0.4.1.tgz
[kubeadmin@docker-registry ~]$ ls tomcat
Chart.yaml  README.md  templates  values.yaml
[kubeadmin@docker-registry ~]$

```

* Installing a chart using helm
```
[kubeadmin@docker-registry ~]$ cd tomcat
[kubeadmin@docker-registry tomcat]$ helm  install ram-tomcat .
NAME: ram-tomcat
LAST DEPLOYED: Sat Jan 11 13:41:16 2020
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
     NOTE: It may take a few minutes for the LoadBalancer IP to be available.
           You can watch the status of by running 'kubectl get svc -w ram-tomcat'
  export SERVICE_IP=$(kubectl get svc --namespace default ram-tomcat -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  echo http://$SERVICE_IP:
[kubeadmin@docker-registry tomcat]$

```

* On kubenetes cluster you can see pod, rc, deployment & services are created for this
```
[root@kube-master ~]# kubectl get deploy
NAME                     READY   UP-TO-DATE   AVAILABLE   AGE
nfs-client-provisioner   1/1     1            1           45d
ram-tomcat               0/1     1            0           111s
[root@kube-master ~]#

[root@kube-master ~]# kubectl get pods
NAME                                      READY   STATUS            RESTARTS   AGE
nfs-client-provisioner-6f689974cb-t6mkk   1/1     Running           0          14d
ram-tomcat-55554dbd57-7fpzz               0/1     PodInitializing   0          36s
[root@kube-master ~]#

[root@kube-master ~]# kubectl get svc -w ram-tomcat
NAME         TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
ram-tomcat   LoadBalancer   10.100.213.248   192.168.58.220   80:32303/TCP   21s
[root@kube-master ~]# 
```
