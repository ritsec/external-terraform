### Data Sources ##############################################################

data "aws_ami" "ubuntu_bionic" {
  most_recent	= true

  filter {
    name		= "name"
    values	= ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name		= "virtualization-type"
    values	= ["hvm"]
  }

  owners	= ["099720109477"]	# Canonical account ID
}

### Resources #################################################################

resource "aws_key_pair" "ops-vault" {
  key_name		= "ops-vault"
  public_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC63aiIX37c4t0kteCP1lT4xS2SIi/EUIhyfvTozME5QeCyXKAvj1HTNslVvYdlLBGzV4dtf9DC8XF9nWmgV1MMqN+5zacbDdeQoYkmM0GYROPwX0sIVmMLHFcTSRuuyNfzuaWr9yznnsi5Ap9ND52EahrYF/XW+z1+8z3bS7Po11ar6xmmhNkUXLVJ1KRW7CmJ9unv201E+sJiW0pVvBQP88GtCx/yWSsZ9wkVRD9qe27AoGACQwZ8Uxl3Emil644RsKiE1fXIX/Ris1zoc9Sy85/7P/X8SAlmamItXUajUEsXnOFpd2wgm0TspkISZZnzEyttLRgdO1N1Cnosid4r RITSEC Ops - Vault"
}

resource "aws_eip" "vault" {
  vpc         = true

  tags = {
    Name = "vault"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_instance" "vault" {
  ami = "${data.aws_ami.ubuntu_bionic.id}"
  instance_type = "t3.small"  # 2 vCPU, 2 GB RAM
  disable_api_termination = "${var.prevent-termination}"
  key_name = "${aws_key_pair.ops-vault.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.standard.id}",
    "${aws_security_group.vault.id}",
  ]
  subnet_id = "${aws_default_subnet.default-az1.id}"
  private_ip = "172.31.0.10"
  user_data_base64 = "${data.template_cloudinit_config.vault.rendered}"

  tags = {
    Name = "vault"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

# A separate EIP association is used to prevent a cyclic dependency
resource "aws_eip_association" "vault" {
  instance_id = "${aws_instance.vault.id}"
  allocation_id = "${aws_eip.vault.id}"
}

resource "aws_ebs_volume" "vault" {
  availability_zone = "us-east-1c"
  size = 5

  tags = {
    Name = "vault"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_volume_attachment" "vault" {
  device_name = "/dev/sdf"
  instance_id = "${aws_instance.vault.id}"
  volume_id = "${aws_ebs_volume.vault.id}"
}