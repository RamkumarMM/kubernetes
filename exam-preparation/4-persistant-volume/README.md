# Peristant Volume

* We may asked to create a Peristant Volume using HostPath method
* pv.yaml contains the code to mount "/mnt" as work-space to the container
* pvc.yaml maps the pv 
* pod.yaml mounts the PV to an nginx pod and maps as default home path on nginx
i.e: ```
	/mnt on worker node is mapped as "/usr/share/nginx/html" on the nginx pod
     ```
* Now if we create/update index.html on /mnt/ path on the worker node will reflect on webpages
