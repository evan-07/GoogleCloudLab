variable "project_id" {
  description = "The ID of the project in which to provision resources."
  type        = string
  default     = "qwiklabs-gcp-02-62f3d2967df7"
}
variable "name" {
  description = "Name of the buckets to create."
  type        = string
  default     = "qwiklabs-gcp-02-62f3d2967df7-bucket"
}