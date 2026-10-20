variable "aws_region" {
  description = "AWS region where the platform will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "securellm"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.33"
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.50.0.0/16"
}
variable "domain_name" {
  description = "Public domain managed in Cloudflare"
  type        = string
  default     = "rogfoundation.org"
}
