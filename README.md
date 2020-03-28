This documentation has been prepared as part of my Kubernetes learning and i tried my best to document everything 

# Lab Setup:

##### Host OS : Windows 10 
##### Hypervisor : VMWare Workstation 12.x
##### Hardware Spec: 
       CPU: Intel i7-4600 CPU @ 2.10 GHz 3rd Gen 
       RAM: 16 GB
       HDD: 256 GB SSD

# Virtual Servers:

![Image of lab](https://github.com/RamkumarMM/kubernetes/blob/master/images/lab-details.jpg)


# Installing & Configuring Docker Private Registry:
##### Hostname: docker-registry.lab.net

#### 1. Installation:
* Create an CentOS 7 Virtual Server and make sure you have /var/lib as a separate Logical Volume
* Docker images will be maintained under /var/lib, so ensure it has enough space
* Configure kubernetes repository, it has docker packages as well 
```
    [root@docker-registry ~]# cat /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
           https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    [root@docker-registry ~]#
```
* Install docker engine by ` yum install docker -y `
* Enable & start docker service ` systemctl enable docker && systemctl start docker `

#### 2. Creating Private Repo:
* Pull the registry image from docker hub ` docker pull registry `
* Run the docker registry container ` docker run -d -p 5000:5000 --restart always --name registry registry:2 `

#### 3. Uploading an container image in Private Repo:
* Pull the image from online ` docker pull nginx`
* Tag it to your local repo 
```
   # docker pull nginx
   # docker tag nginx docker-registry.lab.net:5000/nginx:latest
   # docker push docker-registry.lab.net:5000/nginx:latest
   # docker rmi nginx
```

#### 4. Configuring kubernetes worker node pointing to your private docker registry:
###### Method-1:
* Create file ` vi /etc/docker/daemon.json`
```
    {
        "insecure-registries": ["docker-registry.lab.net:5000"]
    }
```
###### Method-2:
* Edit ` vi /usr/lib/systemd/system/docker.service `  and add the line-no: 19 , save the file
```
[Unit]
      2 Description=Docker Application Container Engine
      3 Documentation=http://docs.docker.com
      4 After=network.target
      5 Wants=docker-storage-setup.service
      6 Requires=docker-cleanup.timer
      7
      8 [Service]
      9 Type=notify
     10 NotifyAccess=main
     11 EnvironmentFile=-/run/containers/registries.conf
     12 EnvironmentFile=-/etc/sysconfig/docker
     13 EnvironmentFile=-/etc/sysconfig/docker-storage
     14 EnvironmentFile=-/etc/sysconfig/docker-network
     15 Environment=GOTRACEBACK=crash
     16 Environment=DOCKER_HTTP_HOST_COMPAT=1
     17 Environment=PATH=/usr/libexec/docker:/usr/bin:/usr/sbin
     18 ExecStart=/usr/bin/dockerd-current \
     19           --insecure-registry docker-registry.lab.net:5000 \
     20           --add-runtime docker-runc=/usr/libexec/docker/docker-runc-current \
     21           --default-runtime=docker-runc \

```
* Reload the daemon ` systemctl daemon-reload `
* Restart docker daemon ` systemct restart docker`

#### 5. Running an container from private registory:
* Lets run the nginx container from private registory
```
docker run -d -p 80:80 docker-registry.lab.net:5000/nginx:latest 
```
* Access your worker node from web browser to confirm nginx is loading.
`` http://kube-worker-1.lab.net ``




# Installing & Configuring Kubernetes cluster:

## Kubernetes Architecture
![Image of Kubenetes Architecure](https://github.com/RamkumarMM/kubernetes/blob/master/images/k8s-architecture.jpg)

### Kubernetes Master Components:
* **API Server:** It kind of gatekeeper for entire cluster, To query any kubernetes object it has to go through API server
* **Scheduler:** It is responsible for physically scheduling pods across the nodes inside the cluster
* **Controller:** It is responsible for overall health of entire cluster, it ensures nodes are up & running and correct no.of pods are running on each nodes as mentioned in the SPEC file
* **etcd:** It the kubernetes centralized database to store the entire kubernetes configuration, including objects it’s creating, secrets and more. It’s  key-value database, any component in kubernetes can query etcd to understand the state of the cluster in real-time

### Kubernetes Worker Node Components:
* **Kubelet:** It’s the primary node agent that runs on each worker nodes in the cluster. It looks at the pod spec that was submitted to the API server on master and ensure that the containers described in the pod specs are running and health. Incase if kubelet notices any failures in the pods running in the worker node then it tries to restart the pods on the same worker node. 
* **Kube-proxy:** It’s an critical element inside the cluster, its responsible for maintaining the entire networking configuration. It’s essentially maintains the distributed networks across all the nodes, all the pods, and across all containers and it also expose the services to the outside world on the internet
* **Container:** It provides the run-time environment for your application, so you run containerized applications process inside these containers


### 1. Building the Virtual Servers:

* Create VM for kube-master & kube-worker nodes with below file system strucure
```    
       /boot         => 200MB
       /             => 3 GB
       swap          => 100MB
       /var/lib      => 5 GB    --------------> This is were all our work-load will run, so it should be separate lv 
```
* I have followed the URL : https://www.linuxtechi.com/install-kubernetes-1-7-centos7-rhel7/ and below are some of the things to high-light
* I used weave-net as my cluster network
* Your Host should not have swap space, Please comment it on /etc/fstab
   ` #/dev/mapper/roovg-swaplv swap                    swap    defaults        0 0   `
* Configure kubernetes repository, it has docker packages as well 
```
    [root@docker-registry ~]# cat /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
    enabled=1
    gpgcheck=1
    repo_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
           https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    [root@docker-registry ~]#
```
* Install docker & kubernetes ` yum install kubeadm docker –y `
* Set the auto startup ` systemctl restart docker && systemctl enable docker `
* Disable firewall, iptables & selinux on your Host
```
       a. systemctl disable firewalld && systemctl stop firewalld
       b. systemctl disable iptables && systemctl disable iptables
       c. sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
```
* Enable docker service ` systemctl enable docker ` 
* Reboot the host
* Add the sysctl entries on your node
```
       # echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
       # vi /etc/sysctl.conf 
              net.bridge.bridge-nf-call-ip6tables = 1
              net.bridge.bridge-nf-call-iptables = 1
              net.bridge.bridge-nf-call-arptables = 1
       #
```
* Reboot the host
* ---------------------  All the above steps should be followed on all nodes ---------------------------------- *

       
### 2. Configuring Kubernetes Master:

* Login to your master node ` # ssh root@kube-master.lab.net `
* Pull the kubernetes cluster images ` # kubeadm config images pull ` ---> This will pull all the images required to install & config kube cluster
* After this, i would suggest to shutdown your VM and convert this as an OVF file. This saves lots of time while doing other exercises
* Power on your VM
* Run the cluster creation command ` [root@kube-master ~]# kubeadm init `  ---> At the end of this command it will give you the command to joining command like: ` kubeadm join 192.168.58.200:6443 --token jqzm4t.3xxxxxxxxxxanoa --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxx `
* Set the kubernetes config on wherever you want to run the commands. either root or your own non-root user ID
```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
* Deploy the POD communication network weave-net
```
[root@kube-master ~]# export kubever=$(kubectl version | base64 | tr -d '\n')
[root@kube-master ~]# kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"
serviceaccount/weave-net created
clusterrole.rbac.authorization.k8s.io/weave-net created
clusterrolebinding.rbac.authorization.k8s.io/weave-net created
role.rbac.authorization.k8s.io/weave-net created
rolebinding.rbac.authorization.k8s.io/weave-net created
daemonset.apps/weave-net created
[root@kube-master ~]#
```
* Check all cluster related pods were up & running
```
[root@kube-master ~]# kubectl get pod --all-namespaces
NAMESPACE     NAME                                          READY   STATUS    RESTARTS   AGE
kube-system   coredns-5644d7b6d9-6cnwc                      1/1     Running   0          10m
kube-system   coredns-5644d7b6d9-brzh6                      1/1     Running   0          10m
kube-system   etcd-kube-master.lab.net                      1/1     Running   0          10m
kube-system   kube-apiserver-kube-master.lab.net            1/1     Running   0          9m57s
kube-system   kube-controller-manager-kube-master.lab.net   1/1     Running   0          10m
kube-system   kube-proxy-fz5qz                              1/1     Running   0          10m
kube-system   kube-scheduler-kube-master.lab.net            1/1     Running   0          9m47s
kube-system   weave-net-hxd9s                               2/2     Running   0          2m14s
[root@kube-master ~]#
```


### 3. Configuring Kubernetes Worker Node:
* Create VM for kube-worker nodes by following the procedure mentioned on 1. Building the Virtual Servers
* Join the worker node to kubernetes cluster 
```
[root@kube-worker-1 ~]# kubeadm join 192.168.58.200:6443 --token jqzm4t.3xxxxxxxxxxanoa --discovery-token-ca-cert-hash sha256:xxxxxxxxxxxxxxxxxxxxxx 
```
* Repeat this on all your worker nodes

### 4. Kubernetes cluster status:
* Now we have configured our cluster, Please do check the status of your cluster by follow command
```
[root@kube-master ~]# kubectl get nodes
NAME                    STATUS   ROLES    AGE    VERSION
kube-master.lab.net     Ready    master   137m   v1.16.2
kube-worker-1.lab.net   Ready    <none>   23m    v1.16.2
kube-worker-2.lab.net   Ready    <none>   21m    v1.16.2
kube-worker-3.lab.net   Ready    <none>   4m5s   v1.16.2
[root@kube-master ~]#
```
* List of pods running on kube-master 
```
[root@kube-master ~]# kubectl get pods --all-namespaces -o wide
NAMESPACE     NAME                                          READY   STATUS    RESTARTS   AGE     IP               NODE                    NOMINATED NODE   READINESS GATES
kube-system   coredns-5644d7b6d9-6cnwc                      1/1     Running   1          139m    10.32.0.2        kube-master.lab.net     <none>           <none>
kube-system   coredns-5644d7b6d9-brzh6                      1/1     Running   1          139m    10.32.0.3        kube-master.lab.net     <none>           <none>
kube-system   etcd-kube-master.lab.net                      1/1     Running   1          138m    192.168.58.200   kube-master.lab.net     <none>           <none>
kube-system   kube-apiserver-kube-master.lab.net            1/1     Running   1          138m    192.168.58.200   kube-master.lab.net     <none>           <none>
kube-system   kube-controller-manager-kube-master.lab.net   1/1     Running   1          138m    192.168.58.200   kube-master.lab.net     <none>           <none>
kube-system   kube-proxy-7hxfr                              1/1     Running   0          25m     192.168.58.201   kube-worker-1.lab.net   <none>           <none>
kube-system   kube-proxy-d6xn7                              1/1     Running   0          22m     192.168.58.202   kube-worker-2.lab.net   <none>           <none>
kube-system   kube-proxy-fz5qz                              1/1     Running   1          139m    192.168.58.200   kube-master.lab.net     <none>           <none>
kube-system   kube-proxy-hdjg5                              1/1     Running   0          5m48s   192.168.58.203   kube-worker-3.lab.net   <none>           <none>
kube-system   kube-scheduler-kube-master.lab.net            1/1     Running   1          137m    192.168.58.200   kube-master.lab.net     <none>           <none>
kube-system   weave-net-hxd9s                               2/2     Running   2          130m    192.168.58.200   kube-master.lab.net     <none>           <none>
kube-system   weave-net-nvhjb                               2/2     Running   1          22m     192.168.58.202   kube-worker-2.lab.net   <none>           <none>
kube-system   weave-net-tbdmz                               2/2     Running   3          25m     192.168.58.201   kube-worker-1.lab.net   <none>           <none>
kube-system   weave-net-z8wjr                               2/2     Running   0          5m48s   192.168.58.203   kube-worker-3.lab.net   <none>           <none>
[root@kube-master ~]#
```
* List of pods' running on each worker node
```
[root@kube-master ~]# kubectl get pods --all-namespaces -o wide | grep kube-worker-1
[root@kube-master ~]# kubectl get pods --all-namespaces -o wide | grep kube-worker-2
[root@kube-master ~]# kubectl get pods --all-namespaces -o wide | grep kube-worker-3
```
* On each worker node below containers were downloaded and they will be auto-run during every reboot
```
[root@kube-worker-1 ~]# docker images
REPOSITORY                        TAG                 IMAGE ID            CREATED             SIZE
k8s.gcr.io/kube-proxy             v1.16.2             8454cbe08dc9        4 days ago          86.1 MB
docker.io/weaveworks/weave-kube   2.5.2               f04a043bb67a        5 months ago        148 MB
docker.io/weaveworks/weave-npc    2.5.2               5ce48e0d813c        5 months ago        49.6 MB
k8s.gcr.io/pause                  3.1                 da86e6ba6ca1        22 months ago       742 kB
[root@kube-worker-1 ~]#
```
* At this point, you should have your kubernetes cluster up & running successfully with your working nodes 

==============================================================================================================================================================

## Let's start exploring various kubernetes components 

### POD: https://github.com/RamkumarMM/kubernetes/blob/master/pod/README.md
### Persistent Volume: https://github.com/RamkumarMM/kubernetes/blob/master/persistent-volume/README.md

**Guys, I have gone through most of the basic topis and right now i am practising Ingress. So i though of creating documentation which practising my lab exercises and i will create missing concepts during weekend**

# Advance Topics 

### Ingress: https://github.com/RamkumarMM/kubernetes/blob/master/ingress/README.md

### Heml: https://github.com/RamkumarMM/kubernetes/blob/master/helm/README.md
