#/bin/bash

if [ $1 == "build" ];
then
  kubectl create -f nginx-deploy.yaml
  kubectl expose deploy nginx-deploy --port=80 --type=LoadBalancer --name=nginx-lb-svc 
elif [ $1 == "clean" ];
then
  kubectl delete service nginx-lb-svc
  kubectl delete deploy nginx-deploy
fi

