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
  public_key  = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE3yUw+Tz9mEFOUKdSCWXeQImrCtnExnpe4oV8g+LCGo RITSEC Ops - Vault"
}

resource "aws_eip" "vault" {
  instance    = "${aws_instance.vault}"
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
    "${aws_security_group.default.id}",
    "${aws_security_group.https.id}",
  ]
  subnet_id = "${aws_default_subnet.default-az1.id}"
  private_id = "172.31.0.1"

  tags = {
    Name = "vault"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
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