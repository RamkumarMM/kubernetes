# Service

* We may get 3 types of question during exam
* First we have to identify the port number on which the pod or deployment is service the application
```
	# kubectl describe pod <pod-name> ----> Look for container port 
	# kubectl describe deploy <deployment-name> -----> Look for container port section

   a. Expose service for application running on a POD (Here, i have exposed the service using NodePort. Depends on the questioner it may chage to ClusterIP or LoadBalancer)
   ```
	# kubectl expose pod <pod-name> --type=NodePort --name=<service-name> ----------> Here, it will automatically connects to the container port of the pod name 
        # kubectl expose pod <pod-name> --port=80 --target-port=3000 ----> Here, we are explicitely mentioned the target port aka container port
   ```
		
   b. Expose service for application running on a Deployment, Here i am expoosing the service as LoadBalancer 
   ```
	# kubectl expose deployment <deployment-name> --port=80 --type=LoadBalancer --name=<service-name>
   ```

   c. Find out the POD nodes for given service name
   ``` 
	# First identify the service 
	# kubectl get service
	# kubectl describe service <service-name> ---> We can find out where its pointed to (Deployment, ReplicaSet or POD)
	# kubectl describe deploy <deployment-name> ---> Find out the pod's 
   ```
