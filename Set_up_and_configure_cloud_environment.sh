#Task 1. Create development VPC manually
gcloud config get compute/zone 
gcloud config get compute/region
gcloud config set compute/zone us-east1-b
gcloud config set compute/region us-east1

gcloud compute networks create griffin-dev-vpc --subnet-mode=custom

gcloud compute networks subnets create griffin-dev-wp \
--network=griffin-dev-vpc \
--range 192.168.16.0/20

gcloud compute networks subnets create griffin-dev-mgmt \
--network=griffin-dev-vpc \
--range 192.168.32.0/20


#Task 2. Create production VPC manually
gcloud config get compute/zone 
gcloud config get compute/region
gcloud config set compute/zone us-east1-b
gcloud config set compute/region us-east1

gcloud compute networks create griffin-prod-vpc --subnet-mode=custom

gcloud compute networks subnets create griffin-prod-wp \
--network=griffin-prod-vpc \
--range 192.168.48.0/20

gcloud compute networks subnets create griffin-prod-mgmt \
--network=griffin-prod-vpc \
--range 192.168.64.0/20

#Task 3. Create bastion host
#Create a bastion host with two network interfaces, one connected to griffin-dev-mgmt and the other connected to griffin-prod-mgmt. Make sure you can SSH to the host.
gcloud compute instances create bastion --machine-type=n1-standard-1 \
--network-interface network=griffin-dev-vpc,subnet=griffin-dev-mgmt \
--network-interface network=griffin-prod-vpc,subnet=griffin-prod-mgmt

gcloud compute firewall-rules create allow-bastion-ssh-dev --allow=tcp:22 \
--description="Allow incoming traffic on TCP port 22" \
--direction=INGRESS --source-ranges="0.0.0.0/0" \
--network=griffin-dev-vpc

gcloud compute firewall-rules create allow-bastion-ssh-prod --allow=tcp:22 \
--description="Allow incoming traffic on TCP port 22" \
--direction=INGRESS --source-ranges="0.0.0.0/0" \
--network=griffin-prod-vpc


#Task 4. Create and configure Cloud SQL Instance
gcloud sql instances create griffin-dev-db --database-version=MYSQL_8_0 --region=us-east1  --cpu=1 --memory=4GB  --root-password=password123
gcloud services enable sqladmin.googleapis.com
gcloud sql connect griffin-dev-db --user=root
#Enter root password which is password123
#Run the following to create wordpress database and account
CREATE DATABASE wordpress;
CREATE USER "wp_user"@"%" IDENTIFIED BY "stormwind_rules";
GRANT ALL PRIVILEGES ON wordpress.* TO "wp_user"@"%";
FLUSH PRIVILEGES;
exit


#Task 5. Create Kubernetes cluster
gcloud container clusters create griffin-dev --zone=us-east1-b --network=griffin-dev-vpc --subnetwork=griffin-dev-wp \
--machine-type=n1-standard-4 --num-nodes=2


#Task 6. Prepare the Kubernetes cluster
gsutil cp -r gs://cloud-training/gsp321/wp-k8s . 
cd ~/wp-k8s
vi wp-env.yaml
gcloud container clusters get-credentials griffin-dev --zone=us-east1
#Edit the user=wp_user and password=stormwind_rules
kubectl apply -f wp-env.yaml


gcloud iam service-accounts keys create key.json \
    --iam-account=cloud-sql-proxy@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com
kubectl create secret generic cloudsql-instance-credentials \
    --from-file key.json


#Task 7. Create a WordPress deployment
vi wp-deployment.yaml
#Edit YOUR_SQL_INSTANCE with griffin-dev-db
kubectl create -f wp-deployment.yaml
kubectl create -f wp-service.yaml


#Task 9. Add a new project editor
gcloud projects add-iam-policy-binding qwiklabs-gcp-04-0ea176cdf4ee \
    --member=user:student-01-95617d4936ea@qwiklabs.net --role=roles/editor