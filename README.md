This documentation has been prepared as part of my Kubernetes learning and i tried my best to document everything 

# Lab Setup:

##### Host OS : Windows 10 
##### Hypervisor : VMWare Workstation 12.x
##### Hardware Spec: 
######     CPU: Intel i7-4600 CPU @ 2.10 GHz 3rd Gen 
######     RAM: 16 GB
######     HDD: 256 GB SSD

# Virtual Servers:

![Image of lab](https://github.com/RamkumarMM/kubernetes/blob/master/images/lab-details.jpg)


# Installing & Configuring Docker Private Registry (Hostname: docker-registry.lab.net):

* Create an CentOS 7 Virtual Server and make sure you have /var/lib as a separate Logical Volume
* Docker images will be maintained under /var/lib, so ensure it has enough space
* Configure kubernetes repository, it has docker packages as well 
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
* Install docker engine by # yum install docker -y
* Enable & start docker service # systemctl enable docker && systemctl start docker

