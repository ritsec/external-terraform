### Data Sources ##############################################################

data "template_file" "ssh" {
  template = "${file("${path.cwd}/scripts/ssh.sh")}"
}

data "template_file" "ebs-volume" {
  template = "${file("${path.cwd}/scripts/ebs-volume.sh")}"
  vars = {
    device = "/dev/sdf"
    mountpoint = "/ebs"
  }
}

data "template_file" "vault-cert" {
  template = "${file("${path.cwd}/scripts/ssl-cert.sh")}"
  vars = {
    certificate = "${acme_certificate.vault.certificate_pem}"
    certificate_path = "/etc/ssl/certs/vault-cert.pem"
    key = "${tls_private_key.vault.private_key_pem}"
    key_path = "/etc/ssl/private/vault-key.pem"
  }
}

data "template_cloudinit_config" "vault" {
  gzip = true
  base64_encode = true

  part {
    filename = "ssh.sh"
    content_type = "text/x-shellscript"
    content = "${data.template_file.ssh.rendered}"
  }

  part {
    filename = "ebs-volume.sh"
    content_type = "text/x-shellscript"
    content = "${data.template_file.ebs-volume.rendered}"
  }

  part {
    filename = "ssl-cert.sh"
    content_type = "text/x-shellscript"
    content = "${data.template_file.vault-cert.rendered}"
  }
}