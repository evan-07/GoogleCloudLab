# Create and Manage Cloud Resources: Challenge Lab
## Define General variables
PROJECT=qwiklabs-gcp-00-8f0581fe4999
INSTANCE=nucleus-jumphost-565
APP_PORT=8080
FIREWALL_RULE=permit-tcp-rule-785
MACHINE_TYPE=f1-micro
ZONE=asia-east1-a

#****** TASK #1
## Create compute instance
gcloud compute instances create $INSTANCE --machine-type $MACHINE_TYPE

#****** TASK #2
## Define variables
CON_MACHINE_TYPE=n1-standard-1
CON_ZONE=us-east1-b
CON_CLUSTER_NAME=cluster1
DEPLOYMENT_NAME=hello-app
DEPLOYMENT_IMAGE=gcr.io/google-samples/hello-app:2.0
SERVICE_NAME=${DEPLOYMENT_NAME}_SERVICE

## Create container cluster
gcloud container clusters create --machine-type=$CON_MACHINE_TYPE --zone=$CON_ZONE $CON_CLUSTER_NAME
## Get credentials used by the newly created cluster
gcloud container clusters get-credentials $CON_CLUSTER_NAME --zone=$CON_ZONE

## Create a new Kubernetes deployment using provided image
kubectl create deployment $DEPLOYMENT_NAME --image=$DEPLOYMENT_IMAGE
## Expose Kubernetes deployment using provided port number
kubectl expose deployment $DEPLOYMENT_NAME --name $SERVICE_NAME --type=LoadBalancer --port $APP_PORT
## Display the External IP of the Service
kubectl describe services $SERVICE_NAME | grep "LoadBalancer Ingress"

## Test connection to the exposed port
EXTERNAL_IP=[Get the LoadBalancer Ingress IP]
curl http://$EXTERNAL_IP:$APP_PORT

# Delete container cluster
gcloud container clusters delete $CON_CLUSTER_NAME --zone=$CON_ZONE

#****** TASK #3
## Create a Load Balancer Template
gcloud compute instance-templates create lb-backend-template \
   --region= \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=e2-medium \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script='#!/bin/bash
     apt-get update
     apt-get install apache2 -y
     a2ensite default-ssl
     a2enmod ssl
     vm_hostname="$(curl -H "Metadata-Flavor:Google" \
     http://169.254.169.254/computeMetadata/v1/instance/name)"
     echo "Page served from: $vm_hostname" | \
     tee /var/www/html/index.html
     systemctl restart apache2'

## Create a managed instance group based on the template
gcloud compute instance-groups managed create lb-backend-group \
   --template=lb-backend-template --size=2 --zone=

## Create a firewall rule
gcloud compute firewall-rules create fw-allow-health-check \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80

## Set up a global static external IP
gcloud compute addresses create lb-ipv4-1 \
  --ip-version=IPV4 \
  --global

## Save the IPv4 address
gcloud compute addresses describe lb-ipv4-1 \
  --format="get(address)" \
  --global

## Create a health check for the load balancer
gcloud compute health-checks create http http-basic-check \
  --port 80

## Create a backend service
gcloud compute backend-services create web-backend-service \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=http-basic-check \
  --global

## Add instance group to the backend service
gcloud compute backend-services add-backend web-backend-service \
  --instance-group=lb-backend-group \
  --instance-group-zone= \
  --global

## Create a URL Map to route incoming requests to the default backend service
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

## Create a target HTTP Proxy
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

## Create a global forwarding rule to route incoming requests to the proxy
gcloud compute forwarding-rules create http-content-rule \
    --address=lb-ipv4-1\
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80