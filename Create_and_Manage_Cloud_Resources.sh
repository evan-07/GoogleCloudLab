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
## Once task is verified, delete the compute instance
gcloud compute instances delete $INSTANCE --zone $ZONE
#---------------------------------------------------------------------------

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

# Once the Cluster is verified, delete container cluster
gcloud container clusters delete $CON_CLUSTER_NAME --zone=$CON_ZONE

#---------------------------------------------------------------------------

#****** TASK #3
## Define variables
INSTANCE_TEMPLATE_NAME=lb-backend-template
INSTANCE_GROUP_NAME=lb-backend-group
INSTANCE_GROUP_SIZE=2
FW_HEALTH_CHECK=fw-allow-health-check
EXTERNAL_IP=lb-ipv4-1
HTTP_PROXY=http-lb-proxy
URL_MAP=web-map-http
BACKEND_SERVICE=web-backend-service
HTTP_HEALTH_CHECK=http-basic-check

## Create a Load Balancer Template
gcloud compute instance-templates create $INSTANCE_TEMPLATE_NAME \
   #--region= \
   --network=default \
   --subnet=default \
   --tags=allow-health-check \
   --machine-type=$MACHINE_TYPE \
   --image-family=debian-11 \
   --image-project=debian-cloud \
   --metadata=startup-script='#! /bin/bash
      apt-get update
      apt-get install -y nginx
      service nginx start
      sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html'

## Create a managed instance group based on the template
gcloud compute instance-groups managed create $INSTANCE_GROUP_NAME \
   --template=$INSTANCE_TEMPLATE_NAME \
   --size=$INSTANCE_GROUP_SIZE \
   --zone=$ZONE

## Create a firewall rule
gcloud compute firewall-rules create $FW_HEALTH_CHECK \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=allow-health-check \
  --rules=tcp:80

## Set up a global static external IP
gcloud compute addresses create $EXTERNAL_IP \
  --ip-version=IPV4 \
  --global

## Save the IPv4 address
gcloud compute addresses describe $EXTERNAL_IP \
  --format="get(address)" \
  --global

## Create a health check for the load balancer
gcloud compute health-checks create http $HTTP_HEALTH_CHECK \
  --port 80

## Create a backend service
gcloud compute backend-services create $BACKEND_SERVICE \
  --protocol=HTTP \
  --port-name=http \
  --health-checks=$HTTP_HEALTH_CHECK \
  --global

## Add instance group to the backend service
gcloud compute backend-services add-backend $BACKEND_SERVICE \
  --instance-group=$INSTANCE_GROUP_NAME \
  --instance-group-zone=$ZONE \
  --global

## Create a URL Map to route incoming requests to the default backend service
gcloud compute url-maps create $URL_MAP \
    --default-service $BACKEND_SERVICE

## Create a target HTTP Proxy
gcloud compute target-http-proxies create $HTTP_PROXY \
    --url-map $URL_MAP

## Create a global forwarding rule to route incoming requests to the proxy
gcloud compute forwarding-rules create http-content-rule \
    --address=$EXTERNAL_IP \
    --global \
    --target-http-proxy=$HTTP_PROXY \
    --ports=80