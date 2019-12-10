kubectl create -f base/ns-and-sa.yaml
kubectl create -f base/default-server-secret.yaml
kubectl create -f base/nginx-config.yaml
kubectl create -f base/rbac.yaml
kubectl create -f base/daemon-set/nginx-ingress.yaml