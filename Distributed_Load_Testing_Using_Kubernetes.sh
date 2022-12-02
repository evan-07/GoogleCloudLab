#https://partner.cloudskillsboost.google/catalog_lab/936
#In this lab you will learn how to use Kubernetes Engine to deploy a distributed load testing framework. The framework uses multiple containers to create load testing traffic for a simple REST-based API. Although this solution tests a simple web application, the same pattern can be used to create more complex load testing scenarios such as gaming or Internet-of-Things (IoT) applications. This solution discusses the general architecture of a container-based load testing framework.

#What you'll learn
#Create a system under test i.e. a small web application deployed to Google App Engine.
#Use Kubernetes Engine to deploy a distributed load testing framework.
#Create load testing traffic for a simple REST-based API.


#-- Set Project and Zone
PROJECT=$(gcloud config get-value project)
REGION=us-central1
ZONE=${REGION}-a
CLUSTER=gke-load-test
TARGET=${PROJECT}.appspot.com
gcloud config set compute/region $REGION
gcloud config set compute/zone $ZONE

#-- Get the sample code and build a Docker image for the application
##-- Get the source code from repository
gsutil -m cp -r gs://spls/gsp182/distributed-load-testing-using-kubernetes .
cd distributed-load-testing-using-kubernetes/
##-- Build docker image and store in container registry
gcloud builds submit --tag gcr.io/$PROJECT/locust-tasks:latest docker-image/.


#-- Deploy web application 
gcloud app deploy sample-webapp/app.yaml

#-- Deploy Kubernetes Cluster
gcloud container clusters create $CLUSTER \
  --zone $ZONE \
  --num-nodes=5


#-- Deploy locust-master
##-- Replace target host and project id with variable values
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[TARGET_HOST\]/$TARGET/g" kubernetes-config/locust-worker-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-master-controller.yaml
sed -i -e "s/\[PROJECT_ID\]/$PROJECT/g" kubernetes-config/locust-worker-controller.yaml
##-- Deploy Locust master
kubectl apply -f kubernetes-config/locust-master-controller.yaml
kubectl get pods -l app=locust-master
##-- Deploy the locust-master-service This step will expose the pod with an internal DNS name (locust-master) and ports 8089, 5557, and 5558. As part of this step, the type: LoadBalancer directive in locust-master-service.yaml will tell Google Kubernetes Engine to create a Compute Engine forwarding-rule from a publicly available IP address to the locust-master pod.
kubectl apply -f kubernetes-config/locust-master-service.yaml
##-- View the newly created forwarding-rule
kubectl get svc locust-master



#-- Deploy locust-worker
kubectl apply -f kubernetes-config/locust-worker-controller.yaml
kubectl get pods -l app=locust-worker
kubectl scale deployment/locust-worker --replicas=20
kubectl get pods -l app=locust-worker

#-- Execute tests
EXTERNAL_IP=$(kubectl get svc locust-master -o yaml | grep ip | awk -F": " '{print $NF}')
echo http://$EXTERNAL_IP:8089
