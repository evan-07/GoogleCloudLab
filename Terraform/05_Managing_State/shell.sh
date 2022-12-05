### Get the Project ID
export projectid=$(gcloud config list --format 'value(core.project)')

### Migrate the Terraform State
terraform init -migrate-state

### Run a container, html file is in /usr/share/nginx/html
docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest

### Docker command to get repo and tag for image, eg. nginx:latest
docker image inspect <IMAGE-ID> -f {{.RepoTags}}

