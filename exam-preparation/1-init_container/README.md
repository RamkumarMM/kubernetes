# init container 

For this we need to mount a volume to your containers. This way the init-container will touch the file and then application container will run only if the init-container successfully creates the file

Following are the list of yaml's required to successfully achive

1. pv.yaml          ---> To create PV (HostPath)
2. pvc.yaml         ---> To create PVC (HostPath)
3. create-pod.yaml  ---> Main code for creating the pod
4. service.yaml     ---> To expose the service on node port
