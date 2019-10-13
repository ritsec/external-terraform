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

resource "aws_key_pair" "ops-gitlab" {
  key_name		= "ops-gitlab"
  public_key	= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCu+Fn6LbAx4pgHLmCe/CSOf5Ho/X5FR6eIbMUNNgbWrgNb75GI9i5fLAFh+RYDT7JztfJfv62kgIzFLzaRaJyZsyWXB+CykQCUNpBuf25tta84aV3DkyJ8h1gZ2b2E0vJB0fzZGsxvdfA5yeyG21ec0z8TQFW6GqHugydOxPD5qqhFvDjKWOLHaYM6IafcieALU2EVK7VtX4peEvkEYPSUxRWxVVjyF//xj4MHEIncGdFsPemIerrXiR1cTwnl1ffCTV2p4E1J3owGx25/Ei0vMIPOJ0D5SVVSuKl5gutYhunb7VwISNVwjcnAQQMa+GHgsUNfT4q2BR0Uyo+Gyxd8Cb9sjSUDnWvqd8pA0tSXSq6DkfyyV5g7cKl3Mfsx+9tA+ZZKOagDXv8Qtdmh1eiGElJtnS2sb0W477qqJjeavTynzxmrLN26A87y+BnSYVclnuUKnL/NcHwFcwANYrAuO8S6flkj6K40FTzO1yrD+bgddau+nEh9nHjB5dC8KiM= RITSEC Ops - GitLab"
}

resource "aws_instance" "gitlab-bastion" {
  ami = "${data.aws_ami.ubuntu_bionic.id}"
  disable_api_termination = "${var.prevent-termination}"
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "t3.nano"
  key_name = "${aws_key_pair.ops-gitlab.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh-bastion.id}",
    "${aws_security_group.default-out.id}",
  ]
  subnet_id = "${aws_subnet.public.id}"
  private_ip = "10.0.0.10"
  user_data = "${var.bastion-bootstrap-script}"

  tags = {
    Name = "gitlab-bastion"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_eip" "gitlab-bastion" {
  vpc         = true
  instance    = "${aws_instance.gitlab-bastion.id}"
  depends_on  = ["aws_internet_gateway.main"]

  tags = {
    Name = "gitlab-bastion"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_instance" "gitlab" {
  ami = "${data.aws_ami.ubuntu_bionic.id}"
  disable_api_termination = "${var.prevent-termination}"
  instance_initiated_shutdown_behavior = "stop"
  instance_type = "m5.large" # 2 vCPU, 8 GB RAM
  key_name = "${aws_key_pair.ops-gitlab.key_name}"
  vpc_security_group_ids = [
    "${aws_security_group.gitlab.id}",
    "${aws_security_group.default-out.id}",
  ]
  subnet_id = "${aws_subnet.public.id}"
  private_ip = "10.0.0.200"

  root_block_device {
    volume_size = 100
    delete_on_termination = true
  }

  tags = {
    Name = "gitlab"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_eip" "gitlab" {
  vpc = true
  instance = "${aws_instance.gitlab.id}"

  tags = {
    Name = "gitlab"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}
