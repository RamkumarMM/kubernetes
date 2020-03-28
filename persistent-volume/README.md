### Persistent Volume
1. Install nfs-utils on any of your Linux server to configure it as NFS Server
	``` # yum install -y nfs-utils```

2. Create a share on the server 
	```
	[root@kube-master ~]# cat /etc/exports
	/storage  *(rw,sync,no_subtree_check,insecure)
	[root@kube-master ~]#
	```


