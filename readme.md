This documentation has been prepared as part of my Kubernetes learning and i tried my best to document everything 

Lab Setup:

Host OS : Windows 10 
Hypervisor : VMWare Workstation 12.x
Virtual Servers:
S.No	FQDN	vCPU 	Memory	HDD	IP Address	Routing	Role
1	kube-master.lab.net	4	4 GB	20 GB	192.168.58.200	NAT to vmnet2 (public)	k8s master
2	kube-worker-1.lab.net	4	4 GB	10 GB	192.168.58.201	NAT to vmnet2 (public)	k8s worker node
3	kube-worker-2.lab.net	4	4 GB	10 GB	192.168.58.202	NAT to vmnet2 (public)	k8s worker node
4	docker-registry.lab.net	2	1 GB	30 GB	192.168.58.210	NAT to vmnet2 (public)	Private Docker Registry & Jenkins Server
5	gitserver.lab.net	2	4 GB	20 GB	192.168.58.50	NAT to vmnet2 (public)	GitLab
