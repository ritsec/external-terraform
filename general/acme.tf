### Resources #################################################################

resource "acme_certificate" "vault" {
  account_key_pem = "${tls_private_key.acme_registration.private_key_pem}"
  certificate_request_pem = "${tls_cert_request.vault.cert_request_pem}"

  dns_challenge {
    provider = "route53"

    config = {
      AWS_DEFAULT_REGION = "us-east-1"
    }
  }
}
