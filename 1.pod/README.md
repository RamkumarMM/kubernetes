# POD

Pod is an atomic unit of scheduling

## POD Diagram

![Image of POD](https://github.com/RamkumarMM/kubernetes/blob/master/images/pod.jpg)

## POD Deployment
* First we have to write the pod manifest file which consists of  container images that we are about to deploy and submit to the API Server
* API Server and the scheduler component on the master node decides where to place this workload on appropriate worker nodes
* Typically 1 pod will used to have 1 container on it. If we want to scale-up or scale-down the application. Then we have to increasing the pods either on the same node or other nodes in the cluster


### Exercise 

* Create the pod
```
[root@kube-master 1.pod]# kubectl create -f nginx-pod-sample.yaml
pod/nginx-pod created
[root@kube-master 1.pod]#
```
* With in few seconds you can see nginx pod is created on your cluster
```
[root@kube-master ~]# kubectl get pods -o wide
NAME                                      READY   STATUS    RESTARTS   AGE     IP          NODE                    NOMINATED NODE   READINESS GATES
nfs-client-provisioner-6f689974cb-f5wn5   1/1     Running   3          7d20h   10.44.0.1   kube-worker-1.lab.net   <none>           <none>
nginx-pod                                 1/1     Running   0          35s     10.44.0.2   kube-worker-1.lab.net   <none>           <none>
[root@kube-master ~]#
```

* Deleting the pod
```
[root@kube-master 1.pod]# kubectl delete -f nginx-pod-sample.yaml
pod "nginx-pod" deleted
[root@kube-master 1.pod]#
```

* With in few seconds your nginx pod will disappear from your cluster
```
[root@kube-master ~]# kubectl get pods -o wide
NAME                                      READY   STATUS    RESTARTS   AGE     IP          NODE                    NOMINATED NODE   READINESS GATES
nfs-client-provisioner-6f689974cb-f5wn5   1/1     Running   3          7d21h   10.44.0.1   kube-worker-1.lab.net   <none>           <none>
[root@kube-master ~]#
```
