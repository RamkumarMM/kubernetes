# Persistent Volume

### Configuring NFS Server
1. Install nfs-utils on any of your Linux server to configure it as NFS Server
	``` 
	# yum install -y nfs-utils
	```

2. Create a share on the server 
	```
	[root@kube-master ~]# cat /etc/exports
	/storage  *(rw,sync,no_subtree_check,insecure)
	[root@kube-master ~]#
	```

3. Set permission
	```
	[root@kube-master ~]# chmod -R 777 /storage
	```

4. Start and enable the nfs service
	```
	[root@kube-master ~]# systemctl enable nfs
	[root@kube-master ~]# systemctl start nfs
	```

5. Check the share point is working
	```
	[root@kube-master ~]# systemctl enable nfs
	[root@kube-master ~]# systemctl start nfs
	```
6. Check the share point is accessiable
	```
	[root@kube-master ~]# showmount -e kube-master.lab.net
	Export list for kube-master.lab.net:
	/storage *
	[root@kube-master ~]# exportfs -v
	/storage        <world>(sync,wdelay,hide,no_subtree_check,sec=sys,rw,insecure,root_squash,no_all_squash)
	[root@kube-master ~]#
	```


# Checking on Client Side
1. Install nfs-utils on kube-worker nodes
	```
	# yum install -y nfs-utils
	```

2. Check the share is accessiable
	```
	[root@kube-worker1 ~]# showmount -e kube-master.lab.net
	Export list for kube-master.lab.net:
	/storage *
	[root@kube-worker1 ~]#
	```

3. Check its mounting on the server
	```
	[root@kube-worker1 ~]# mount -t nfs kube-master.lab.net:/storage /mnt/
	[root@kube-worker1 ~]# echo $?
	0
	[root@kube-worker1 ~]# df -h /mnt/
	Filesystem                    Size  Used Avail Use% Mounted on
	kube-master.lab.net:/storage   20G  2.8G   17G  14% /mnt
	[root@kube-worker1 ~]#
	```

4. Repeat this testing on all your worker nodes to confirm NFS mount is properly working

