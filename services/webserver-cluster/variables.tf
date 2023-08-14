variable "server_port" {
  description = "Server port for Nginx"
  default     = 8080
}

variable "cluster_name" {
  description = "The name to user for all cluster resources."
  type        = string
}

variable "db_remote_state_bucket" {
  description = "The name of S3 buckets for db's remote state."
  type        = string
}

variable "db_remote_state_key" {
  description = "The path for db's remote state in S3 bucket."
  type        = string
}

variable "ssh_key_name" {
  description = "SSH key name for ssh acces to instance."
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of instances."
  type        = number
  default     = 2
}

variable "custom_tag" {
  description = "value"
  type        = map(string)
  default     = {}
}