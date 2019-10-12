### Data Sources ##############################################################

### Resources #################################################################

resource "aws_ses_domain_identity" "main" {
  domain    = "${data.aws_route53_zone.ritsec-cloud.name}"
}

resource "aws_ses_domain_identity_verification" "main" {
  domain      = "${aws_ses_domain_identity.main.domain}"
  depends_on  = ["aws_route53_record.ses-verification"]
}

resource "aws_ses_domain_dkim" "main" {
  domain      = "${aws_ses_domain_identity.main.domain}"
  depends_on  = ["aws_ses_domain_identity_verification.main"]
}
