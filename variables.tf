variable "rancher_domain_name" {
  description = "Domain name of rancher server"
  type        = string
  default     = "rancher.heheszlo.com"
}

variable "http_node_port" {
  description = "NodePort for Rancher HTTP service"
  type        = number
  default     = 31069
}