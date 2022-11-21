## Task 1

### Define provider
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}


## Task 2

### Add module reference to create instances using ./modules/instances
module "instances" {
  source     = "./modules/instances"
}

