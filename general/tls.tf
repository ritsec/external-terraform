### Resources #################################################################

resource "tls_private_key" "acme_registration" {
  algorithm = "RSA"
}

resource "tls_private_key" "vault" {
  algorithm = "RSA"
}

resource "tls_cert_request" "vault" {
  key_algorithm = "RSA"
  private_key_pem = "${tls_private_key.vault.private_key_pem}"

  subject {
    common_name = "${aws_route53_record.vault.fqdn}"
    organization = "RITSEC"
    organizational_unit = "Operations Program"
    locality = "Rochester"
    province = "New-York"
    country = "US"
    postal_code = "14623"
  }
}