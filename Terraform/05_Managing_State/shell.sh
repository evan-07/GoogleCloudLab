### Get the Project ID
export projectid=$(gcloud config list --format 'value(core.project)')

### Migrate the Terraform State
terraform init -migrate-state

### Docker command to get repo and tag for image, eg. nginx:latest
docker image inspect <IMAGE-ID> -f {{.RepoTags}}

