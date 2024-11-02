output "domain_name" {
  value = scaleway_object_bucket_website_configuration.website.website_endpoint
}
