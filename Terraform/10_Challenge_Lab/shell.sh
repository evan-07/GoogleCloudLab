## Task 1 - Cerate the configuration files
### Create directories
touch main.tf
touch variables.tf
mkdir modules
mkdir modules/instances
touch modules/instances/instances.tf
touch modules/instances/outputs.tf
touch modules/instances/variables.tf
mkdir modules/storage
touch modules/storage/storage.tf
touch modules/storage/outputs.tf
touch modules/storage/variables.tf

### Get the Project ID
export projectid=$(gcloud config list --format 'value(core.project)')

### Initialize
terraform init

## Task 2 - Import Infrastructure
### Update main.tf and include call for instances module

### Initialize 
terraform init

### Get the instance ID of tf-instance-1 and tf-instance-2
### 


### Import
terraform import module.instances.google_compute_instance.tf-instance-1 <FILL IN INSTANCE 1 ID>
#terraform import module.instances.google_compute_instance.tf-instance-1 3724940193142573266

terraform import module.instances.google_compute_instance.tf-instance-2 <FILL IN INSTANCE 2 ID>
#terraform import module.instances.google_compute_instance.tf-instance-2 5316954475210377426

terraform plan
terraform apply
