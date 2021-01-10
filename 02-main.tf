data "azurerm_client_config" "current" {}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address = var.registration_email_address
}

resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  min_days_remaining = 30
  certificate_p12_password = var.certificate_p12_password
  dns_challenge {
    provider = "azure"
    config = {
      AZURE_CLIENT_ID = var.azure_client_id,
      AZURE_CLIENT_SECRET = var.azure_client_secret,
      AZURE_RESOURCE_GROUP = var.azure_resource_group,
      AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id,
      AZURE_TENANT_ID = data.azurerm_client_config.current.tenant_id
    }
  }
}

resource "local_file" "private_key_pem" {
  content     = acme_certificate.certificate.private_key_pem
  filename = "${var.output_path}/${var.name}-key.pem"
}

resource "local_file" "certificate_pem" {
  content     = acme_certificate.certificate.certificate_pem
  filename = "${var.output_path}/${var.name}-cert.pem"
}

resource "local_file" "issuer_perm" {
  content = join("", [acme_certificate.certificate.issuer_pem, acme_certificate.certificate.certificate_pem])
  filename = "${var.output_path}/${var.name}-full-cert.pem"
}