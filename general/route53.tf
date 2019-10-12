### Data Sources ##############################################################

data "aws_route53_zone" "ritsec-cloud" {
  name  = "ritsec.cloud."
}

### Resources #################################################################

resource "aws_route53_record" "vault" {
  zone_id = "${data.aws_route53_zone.ritsec-cloud.id}"
  name    = "vault"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.vault.public_ip}"]
}