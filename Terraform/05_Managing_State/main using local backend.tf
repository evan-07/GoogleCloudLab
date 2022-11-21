terraform {
  backend "local" {
    path = "terraform/state/terraform.tfstate"
  }
}
provider "google" {
  project     = "qwiklabs-gcp-01-fd6022c3ed79"
  region      = "us-central-1"
}
resource "google_storage_bucket" "test-bucket-for-state" {
  name        = "qwiklabs-gcp-01-fd6022c3ed79"
  location    = "US"
  uniform_bucket_level_access = true
}