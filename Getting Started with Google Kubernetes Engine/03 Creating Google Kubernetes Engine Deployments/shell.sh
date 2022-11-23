# Set environment variables


## Task 1. Create deployment manifests and deploy to the cluster

### Connect to the lab GKE cluster
#### Set environment variables
export my_zone=us-central1-a
export my_cluster=standard-cluster-1
#### Configure kubectl tab completion
source <(kubectl completion bash)
#### Configure access to your cluster for the kubectl command-line tool
gcloud container clusters get-credentials $my_cluster --zone $my_zone
#### Clone repository 
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
#### Create a soft link as shortcut to the working directory
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
#### Change to the directory
cd ~/ak8s/Deployments/

### Create a deployment manifest
#### Deploy manifest by executing dommand
kubectl apply -f ./nginx-deployment.yaml
#### View list of deployments
kubectl get deployments


## Task 2. Manually scale up and down the unmber of Pods in deployments

### Scale Pods up and down in the shell
#### View list of deployments to see initial number of replicas
kubectl get deployments
#### Scale the pod to 3 replicas
kubectl scale --replicas=3 deployment nginx-deployment
#### View list of deployments to verify
kubectl get deployments


## Task 3. Trigger a deployment rollout and a deployment rollback

### Trigger a deployment rollout
#### Update the version of nginx in the deployment to nginx v1.9.1
kubectl set image deployment.v1.apps/nginx-deployment nginx=nginx:1.9.1 --record
#### View rollout status
kubectl rollout status deployment.v1.apps/nginx-deployment
#### Verify the change 
kubectl get deployments
#### View the rollout history of the deployment
kubectl rollout history deployment nginx-deployment

### Trigger a deployment rollback
#### Rollback previous version of the nginx deployment
kubectl rollout undo deployments nginx-deployment
#### View the updated rollout history of the deployment
kubectl rollout history deployment nginx-deployment
#### View the details of the latest deployment revision
kubectl rollout history deployment/nginx-deployment --revision=3


## Task 4. Define the service type in the manifest

### Apply service types in the manifest
kubectl apply -f ./service-nginx.yaml
### Verify LoadBalancer creation
kubectl get service nginx


## Task 5. Perform a canary deployment

### Apply the canary based deployment based on the configuration file
kubectl apply -f nginx-canary.yaml
### Verify that both nginx and nginxcanary deployments are present
kubectl get deployments
###Scale down primary depoyment to 0 replicas
kubectl scale --replicas=0 deployment nginx-deployment