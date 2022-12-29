variable "project" {
  type        = string
  description = "GCP project id"
}

variable "region" {
  type        = string
  description = "GCP project region"
}

variable "zone" {
  type        = string
  description = "GCP project zone"
}

variable "nodes_map" {
  type        = list(map(string))
  description = "List of key-par objects that uses the following structure: {'name' = 'my-name', 'is-master' = false|true } "
}

variable "gce_host_username" {
  type        = string
  description = "Username used to login via ssh"
}

variable "gce_ssh_key_file_path" {
  type        = string
  description = "Path to a id_rsa.pub file to be used to validate ssh authentication"
}

variable "master_script" {
  type        = string
  description = "Script used to setup the master node"
}

variable "worker_script" {
  type        = string
  description = "Scritp used to setup the workers node"
}

variable "master_instance_type" {
  type        = string
  description = "Master instance type"
}

variable "worker_instance_type" {
  type        = string
  description = "Worker instance type"
}

variable "os_image" {
  type        = string
  description = "OS image used in all nodes"
}
