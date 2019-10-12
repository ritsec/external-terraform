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
}