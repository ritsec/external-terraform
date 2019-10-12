### Data Sources ##############################################################

data "aws_route53_zone" "ritsec-cloud" {
  name  = "ritsec.cloud."
}

### Resources #################################################################

resource "aws_route53_record" "gitlab" {
  zone_id = "${data.aws_route53_zone.ritsec-cloud.id}"
  name    = "gitlab"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.gitlab.public_ip}"]
}

resource "aws_route53_record" "gitlab-bastion" {
  zone_id = "${data.aws_route53_zone.ritsec-cloud.id}"
  name    = "jump"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.gitlab-bastion.public_ip}"]
}

resource "aws_route53_record" "ses-verification" {
  zone_id = "${data.aws_route53_zone.ritsec-cloud.id}"
  name    = "_amazonses.${data.aws_route53_zone.ritsec-cloud.name}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.main.verification_token}"]
}

resource "aws_route53_record" "ses-dkim" {
  count   = 3
  zone_id = "${data.aws_route53_zone.ritsec-cloud.id}"
  name    = "${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}._domainkey.${data.aws_route53_zone.ritsec-cloud.name}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.main.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_route53_record" "ses-dmarc" {
  zone_id = "${data.aws_route53_zone.ritsec-cloud.id}"
  name    = "_dmarc.${data.aws_route53_zone.ritsec-cloud.name}"
  type    = "TXT"
  ttl     = "600"
  records = ["v=DMARC1;p=quarantine;sp=quarantine;pct=100;rua=mailto:dmarcreports@${data.aws_route53_zone.ritsec-cloud.name};ruf=mailto:dmarcreports@${data.aws_route53_zone.ritsec-cloud.name}"]
}
