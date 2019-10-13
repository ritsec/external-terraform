### Resources #################################################################

resource "acme_registration" "vault" {
  account_key_pem = "${tls_private_key.acme_registration.private_key_pem}"
  email_address = "ops@ritsec.club"  # TODO: make this a real email
}

resource "acme_certificate" "vault" {
  account_key_pem = "${tls_private_key.acme_registration.private_key_pem}"
  certificate_request_pem = "${tls_cert_request.vault.cert_request_pem}"

  dns_challenge {
    provider = "route53"

    config = {
      AWS_DEFAULT_REGION = "us-east-1"
      AWS_HOSTED_ZONE_ID = "${data.aws_route53_zone.ritsec-cloud.id}"
      AWS_PROFILE = "ritsec"
    }
  }
}
