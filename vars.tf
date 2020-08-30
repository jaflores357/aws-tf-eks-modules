variable "region" {
  default     = "us-east-2"
  description = "AWS region"
}

variable "cluster-name" {
  default = "southsystem"
  type    = string
}

variable "workers_instance_type" {
  default = {
    dev = "t3a.small"
  }
}

variable "workers_desired_size" {
  default = {
    dev = "2"
  }
}

variable "workers_min_size" {
  default = {
    dev = "1"
  }
}

variable "workers_max_size" {
  default = {
    dev = "3"
  }
}

