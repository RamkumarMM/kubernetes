# Troubleshooting K8S worker node

* During exam, we may get a question related to a non-working worker node and we need to fix it. 
* We have to use our SysAdmin skills to find out the issue and fix it. 
* Below are few of the important commands & files to troubleshoot
	* 1. systemctl status kubelet
	* 2. Configuration file: /etc/kubernetes/kubelet.conf
	* 3. Manifest file: /var/lib/kubelet/config.yaml
	* 4. Extra Arugments to kubelet daemon: /etc/sysconfig/kubelet
        * 5. After fixing the issue reload the service by ``` systemctl daemon-reload ```
	* 6. Start the service ```  systemctl restart kubelet ```
