This document is for how to configure bash auto-completion for bash

# Install the following rpm 
```
# yum install bash-completion.noarch bash-completion-extras.noarch -y
 ```

# Setting up your bashrc, just run the below commands
```
# source /usr/share/bash-completion/bash_completion
# echo 'source <(kubectl completion bash)' >> ~/.bashrc
# kubectl completion bash >/etc/bash_completion.d/kubectl
```

# Restart your shell and you can see kubectl commands get autoload when tab is press
```
[root@kube-master ~]# kubectl
annotate       auth           config         delete         exec           label          port-forward   scale          version
api-resources  autoscale      convert        describe       explain        logs           proxy          set            wait
api-versions   certificate    cordon         diff           expose         options        replace        taint
apply          cluster-info   cp             drain          get            patch          rollout        top
attach         completion     create         edit           kustomize      plugin         run            uncordon
[root@kube-master ~]# kubectl
```

