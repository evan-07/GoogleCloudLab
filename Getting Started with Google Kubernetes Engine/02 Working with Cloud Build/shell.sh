# Task 2. Building containers with DockerFile and Cloud Build
## 1. Create Dockerfile and quickstart.sh
## 2. Make quickstart file executable
chmod +x quickstart.sh
## 3. Build container image in Cloud Build
gcloud builds submit --tag gcr.io/${GOOGLE_CLOUD_PROJECT}/quickstart-image .

# Task 3. Building containers with a build configuration file and Cloud Build
## 1. Clone repository to Clode Shell
git clone https://github.com/GoogleCloudPlatform/training-data-analyst
## 2. Create a soft link as a shortcut to the working directory
ln -s ~/training-data-analyst/courses/ak8s/v1.1 ~/ak8s
## 3. Change directory to the sample files
cd ~/ak8s/Cloud_Build/a
## 4. Cat Cloudbuild.yaml file
cat cloudbuild.yaml
## 5. Start a Cloud Build using cloudbuild.yaml as the build configuration file
gcloud builds submit --config cloudbuild.yaml .

# Task 4. Building and testing containers with a build configuration file and Cloud Build
## 1. Change directory to the sample files
cd ~/ak8s/Cloud_Build/b
## 2. Cat Cloudbuild.yaml file
cat cloudbuild.yaml
## 3. Start a Cloud Build using cloudbuild.yaml as the build configuration file while passing a fail parameter 
gcloud builds submit --config cloudbuild.yaml .