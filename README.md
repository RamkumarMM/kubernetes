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

* Create an CentOS 7 Virtual Server and make sure you have /var/lib as a separate Logical Volume
* Docker images will be maintained under /var/lib, so ensure it has enough space
