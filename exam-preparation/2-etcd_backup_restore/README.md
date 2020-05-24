# ETCD Backup & Restore

1. We have to provide CACert, etcd-cert & etcd-key file to all commands, so please node the absolute path from 
``` 
# kubectl -n kube-system describe pod <etcd-master-pod> 
```

2. To take backup 
``` 
# ETCDCTL_API=3 etcdctl snapsnot save /tmp/etcd-snapshot-backup.db \
          --endpoints=https://127.0.0.1:2379 \
          --cacert=/etc/etcd/ca.crt \
          --cert=/etc/etcd/etcd-server.crt \
          --key=/etc/etcd/etcd-server.key 
```

3. Stop api-server during restore, if kubernetes cluster in build in hard-way (components are installed as services instead of container based `kubeadm init` way)
``` 
# service kube-apiserver stop 
```

4. We can restore in 2 ways 
	* Completely from command line, works only if cluster created in hard-way
	

5. Now you can see the pods, services, deployments, replication sets are restored
