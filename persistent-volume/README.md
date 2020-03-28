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

3. Create a directory for Persistant volume and Set permission
	```
	[root@kube-master ~]# mkdir /storage/persistent-volumes
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


# Creating Persistant Volume
1. Below is our Persistant volume manifests and high-lighted iteams are important notes
	```
	apiVersion: v1
	kind: PersistentVolume
	metadata:
	  name: nfs-pv-vol-1	-----------------> Name of the Persistant Volume
	  labels:
	    type: local
	spec:
	  storageClassName: nfsmount	---------> Name of the Storage Class (Should be in Lowercase)
	  capacity:
	    storage: 500Mi	-----------------> Size of the PV
	  accessModes:
	    - ReadWriteMany	-----------------> Access Policy
	  nfs:
	    server: kube-master.lab.net
	    path: /storage/persistent-volumes ---> NFS Storage Location
	```

2. Create the Persistant volume 
	```
	[kubeadmin@devops-server persistent-volume]$ kubectl create -f pv.yaml
	persistentvolume/nfs-pv-vol-1 created
	[kubeadmin@devops-server persistent-volume]$
	[kubeadmin@devops-server persistent-volume]$ kubectl get pv
	NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
	nfs-pv-vol-1   500Mi      RWX            Retain           Available           nfsmount                7s
	[kubeadmin@devops-server persistent-volume]$
	```
*** Now the Persistant Volume is created, but not bounded to any claim ***

