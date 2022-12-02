#https://partner.cloudskillsboost.google/catalog_lab/486



gcloud config set compute/zone us-central1-b
gcloud container clusters create io
gcloud container clusters get-credentials io

gsutil cp -r gs://spls/gsp021/* .
cd orchestrate-with-kubernetes/kubernetes

#-- Create deployment which keeps pods up and running even when nodes they run on fail
kubectl create deployment nginx --image=nginx:1.10.0
kubectl get pods
kubectl expose deployment nginx --port 80 --type LoadBalancer
kubectl get services

#-- Creating Pods named monolith
cd ~/orchestrate-with-kubernetes/kubernetes
kubectl create -f pods/monolith.yaml
kubectl get pods
kubectl describe pods monolith

#-- Creating port-forwarding to map a local port to a port inside the monolith pod
kubectl port-forward monolith 10080:80
curl http://127.0.0.1:10080
curl http://127.0.0.1:10080/secure
curl -u user http://127.0.0.1:10080/login
TOKEN=$(curl http://127.0.0.1:10080/login -u user|jq -r '.token')
curl -H "Authorization: Bearer $TOKEN" http://127.0.0.1:10080/secure
kubectl logs monolith
####using another terminal
kubectl logs -f monolith
####back to original terminal
curl http://127.0.0.1:10080
kubectl exec monolith --stdin --tty -c monolith -- /bin/sh
ping -c 3 google.com


#-- Run an interactive shell insite the Monolith pod
kubectl exec monolith --stdin --tty -c monolith -- /bin/sh

#-- Creating service for monolith
cd ~/orchestrate-with-kubernetes/kubernetes
cat pods/secure-monolith.yaml
kubectl create secret generic tls-certs --from-file tls/
kubectl create configmap nginx-proxy-conf --from-file nginx/proxy.conf
kubectl create -f pods/secure-monolith.yaml
kubectl create -f services/monolith.yaml
gcloud compute firewall-rules create allow-monolith-nodeport --allow=tcp:31000


#-- Adding labels to pods 
kubectl get pods -l "app=monolith"
kubectl get pods -l "app=monolith,secure=enabled"
kubectl label pods secure-monolith 'secure=enabled'
kubectl get pods secure-monolith --show-labels
kubectl describe services monolith | grep Endpoints
gcloud compute instances list
curl -k https://<EXTERNAL_IP>:31000


#-- Creating deployments for monolith application
kubectl create -f deployments/auth.yaml
kubectl create -f services/auth.yaml
kubectl create -f deployments/hello.yaml
kubectl create -f services/hello.yaml
kubectl create configmap nginx-frontend-conf --from-file=nginx/frontend.conf
kubectl create -f deployments/frontend.yaml
kubectl create -f services/frontend.yaml
kubectl get services frontend
curl -k https://<EXTERNAL-IP>
