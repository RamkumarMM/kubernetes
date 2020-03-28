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


# Binding PV to Persistant Volume Claim
1. Create the persistant volume claim manifest and high-lighed items are important to remember
	```
	apiVersion: v1
	kind: PersistentVolumeClaim
	metadata:
	  name: nfs-pvc-vol-1	------------------> Name of the Persistant Volume to Bind
	spec:
	  storageClassName: nfsmount	----------> Name of the Storage class (Should be match with the PV manifest)
	  accessModes:
	    - ReadWriteMany	------------------> Access Policy (Should be match with the PV manifest, otherwise it won't bind)
	  resources:
	    requests:
	      storage: 500Mi	------------------> Size of the request, Must be less then available PV size with respective policies
	```

2. Create the Persistant volume claim
	```
	[kubeadmin@devops-server persistent-volume]$ kubectl create -f pvc.yaml
	persistentvolumeclaim/nfs-pvc-vol-1 created
	[kubeadmin@devops-server persistent-volume]$
	[kubeadmin@devops-server persistent-volume]$ kubectl get pvc
	NAME            STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
	nfs-pvc-vol-1   Bound    nfs-pv-vol-1   500Mi      RWX            nfsmount       4s
	[kubeadmin@devops-server persistent-volume]$
	```

*** Now the PV has been binded to this claim request ***

3. We can run `kubectl get pv, pvc` to see active pv and pvc
	```
	[kubeadmin@devops-server persistent-volume]$ kubectl get pv,pvc
	NAME                            CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                   STORAGECLASS   REASON   AGE
	persistentvolume/nfs-pv-vol-1   500Mi      RWX            Retain           Bound    default/nfs-pvc-vol-1   nfsmount                9m4s
	
	NAME                                  STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
	persistentvolumeclaim/nfs-pvc-vol-1   Bound    nfs-pv-vol-1   500Mi      RWX            nfsmount       85s
	[kubeadmin@devops-server persistent-volume]$
	```
	

# Mapping the volume to a POD
1. Create a POD manifests, Use the pod-deploy.yaml
	````
	[kubeadmin@devops-server persistent-volume]$ kubectl create -f pod-deploy.yaml
	deployment.apps/nginx-deploy created
	[kubeadmin@devops-server persistent-volume]$
	[kubeadmin@devops-server persistent-volume]$ kubectl get pods
	NAME                           READY   STATUS    RESTARTS   AGE
	nginx-deploy-9946c5c84-sxgrg   1/1     Running   0          8s
	[kubeadmin@devops-server persistent-volume]$
	```

2. Now check in which kube-worker node the pod has been scheduled
	```
	[kubeadmin@devops-server ~]$ kubectl get pod -o wide
	NAME                           READY   STATUS    RESTARTS   AGE     IP          NODE                   NOMINATED NODE   READINESS GATES
	nginx-deploy-9946c5c84-sxgrg   1/1     Running   0          6m58s   10.36.0.1   kube-worker2.lab.net   <none>           <none>
	[kubeadmin@devops-server ~]$
	```
	So, this is scheduled on kube-worker2.lab.net host

3. Logon to kube-worker2 node to check the NFS share has been mounted on it
	```
	[root@kube-worker2 ~]# mount | grep nfs
	kube-master.lab.net:/storage/persistent-volumes on /var/lib/kubelet/pods/f8c4cb87-362d-497d-b979-96b7dc670ba2/volumes/kubernetes.io~nfs/nfs-pv-vol-1 type nfs4 (rw,relatime,vers=4.1,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,clientaddr=192.168.58.102,local_lock=none,addr=192.168.58.100)
	[root@kube-worker2 ~]#
	```

# Creating index.html from nfs server
1. Login to the NFS server and create the index.html file to be serviced via the POD
	```
	[root@kube-master persistent-volumes]# pwd
	/storage/persistent-volumes
	[root@kube-master persistent-volumes]# cat index.html
	<h1> Welcome to my NGINX Page by Ram </h1>
	[root@kube-master persistent-volumes]#


# Checking the index.html accessiable inside the container
1. Login to the container in interactive mode
	```
	[kubeadmin@devops-server persistent-volume]$ kubectl exec -it nginx-deploy-9946c5c84-sxgrg  -- /bin/sh
	# ls /usr/share/nginx/html
	index.html
	# cat /usr/share/nginx/html/index.html
	<h1> Welcome to my NGINX Page by Ram </h1>
	# exit
	[kubeadmin@devops-server persistent-volume]$
	```


# Expose the POD / Deployment in to a service
1. Run the kubectl expose to expose the service
	```
	[kubeadmin@devops-server ~]$ kubectl expose deploy nginx-deploy --port 80 --type NodePort
	service/nginx-deploy exposed
	[kubeadmin@devops-server ~]$ kubectl get svc
	NAME           TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
	kubernetes     ClusterIP   10.96.0.1      <none>        443/TCP        4h6m
	nginx-deploy   NodePort    10.110.40.42   <none>        80:30063/TCP   4s
	[kubeadmin@devops-server ~]$
	```	

2. Access the URL 
