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
`` docker run -d -p 80:80 docker-registry.lab.net:5000/nginx:latest ``
* Access your worker node from web browser to confirm nginx is loading.
`` http://kube-worker-1.lab.net ``
