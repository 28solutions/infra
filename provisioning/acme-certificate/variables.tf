variable "account_key_pem" {
  type        = string
  description = "ACME account key"
}

variable "common_name" {
  type        = string
  description = "Certificate common name"
}

variable "dns_names" {
  type        = list(string)
  description = "Certificate DNS names"
}
