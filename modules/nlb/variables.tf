variable "name_prefix" {
  description = "Prefix for NLB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the NLB"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the NLB"
  type        = list(string)
}
