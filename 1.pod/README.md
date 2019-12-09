# POD

Pod is an atomic unit of scheduling

## POD Diagram

![Image of POD](https://github.com/RamkumarMM/kubernetes/blob/master/images/pod.jpg)

## POD Deployment
* First we have to write the pod manifest file which consists of  container images that we are about to deploy and submit to the API Server
* API Server and the scheduler component on the master node decides where to place this workload on appropriate worker nodes
* Typically 1 pod will used to have 1 container on it. If we want to scale-up or scale-down the application. Then we have to increasing the pods either on the same node or other nodes in the cluster

