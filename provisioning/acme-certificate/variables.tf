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

variable "cloudflare_tokens" {
  type = object({
    zone_read = string
    dns_edit  = string
  })

  description = "Cloudflare Zone:Read and DNS:Edit tokens"
  sensitive   = true
}
