# Troubleshooting K8S worker node

* During exam, we may get a question related to a non-working worker node and we need to fix it. 
* We have to use our SysAdmin skills to find out the issue and fix it. 
* Below are few of the important commands & files to troubleshoot
	a. systemctl status kubelet
	b. Configuration file: /etc/kubernetes/kubelet.conf
	c. Manifest file: /var/lib/kubelet/config.yaml
	d. Extra Arugments to kubelet daemon: /etc/sysconfig/kubelet
        e. After fixing the issue reload the service by ``` systemctl daemon-reload ```
	f. Start the service ```  systemctl restart kubelet ```
