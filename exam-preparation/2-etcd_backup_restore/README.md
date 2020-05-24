# ETCD Backup & Restore

1. We have to provide CACert, etcd-cert & etcd-key file to all commands, so please node the absolute path from 
	``` # kubectl -n kube-system describe pod <etcd-master-pod> ```

2. To take backup \
``` # ETCDCTL_API=3 etcdctl snapsnot save /tmp/etcd-snapshot-backup.db \
          --endpoints=https://127.0.0.1:2379 \
          --cacert=/etc/etcd/ca.crt \
          --cert=/etc/etcd/etcd-server.crt \
          --key=/etc/etcd/etcd-server.key ```

3. Stop api-server during restore, if kubernetes cluster in build in hard-way (components are installed as services instead of container based `kubeadm init` way)
	``` # service kube-apiserver stop ```

4. We can restore in 2 ways 
	a. Completely from command line, works only if cluster created in hard-way
           Step-1: 
	   ``` # ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-snapshot-backup.db \
		--data-dir=/var/lib/etcd-from-backup \
		--initial-cluster master-1=https://192.168.58.100:2380,master-2=https://192.168.58.200:2380 \
		--initial-cluster-token etcd-cluster-1 \
		--initial-advertise-peer-urls https://${INTERNAL_IP}:2380 ```
           Step-2: ``` # systemctl daemon-reload ```
           Step-3: ``` # service kube-apiserver start ```
	   Step-4: ``` # service etcd restart ```

        b. If cluster build using `kubeadm init` way, then
	   Step-1:
	   ``` # ETCDCTL_API=3 etcdctl snapshot restore /tmp/etcd-snapshot-backup.db \
                  --endpoints=https://127.0.0.1:2379 \
	          --cacert=/etc/etcd/ca.crt \
	          --cert=/etc/etcd/etcd-server.crt \
        	  --key=/etc/etcd/etcd-server.key ```
           Step-2: Edit /etc/kubernetes/manifests/etcd.yaml
	   Step-3: Update "--data-dir=/var/lib/etcd" to "--data-dir=/var/lib/etcd-from-backup"
                   Add    "--initial-cluster-token etcd-cluster-1" 
	   Step-4: Save the file and kubernetes will automatically initiates the etcd from backup location
	

5. Now you can see the pods, services, deployments, replication sets are restored
