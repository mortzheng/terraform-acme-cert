variable "name" {
}

variable "domain" {
}

variable "registration_email_address" {
  default = "mortzheng@foodtruckinc.com"
}

variable "certificate_p12_password" {
  type = string
}

variable "output_path" {
  default = "./certs"
}

variable "azure_client_id" {}
variable "azure_client_secret" {}
variable "azure_resource_group" {}