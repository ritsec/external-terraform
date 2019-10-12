### Resources #################################################################

resource "aws_default_vpc" "default" {

  tags = {
    Name = "default"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_default_subnet" "default-az1" {
  availability_zone = "us-east-1c"

  tags = {
    Name = "default-az1"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_default_subnet" "default-az2" {
  availability_zone = "us-east-1d"

  tags = {
    Name = "default-az2"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_default_subnet" "default-az3" {
  availability_zone = "us-east-1e"

  tags = {
    Name = "default-az3"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_default_subnet" "default-az4" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "default-az4"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_default_subnet" "default-az5" {
  availability_zone = "us-east-1f"

  tags = {
    Name = "default-az5"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_default_subnet" "default-az6" {
  availability_zone = "us-east-1b"

  tags = {
    Name = "default-az6"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_security_group" "default" {
  name = "default"
  description = "Security group for all instances deployed in the default VPC."
  vpc_id = "${aws_default_vpc.default}"

  tags = {
    Name = "default"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_security_group_rule" "high-ssh" {
  type = "ingress"
  protocol = "tcp"
  from_port = 65432
  to_port = 65432
  description = "Allows external traffic to SSH on a high port."

  security_group_id = "${aws_security_group.default}"
}

resource "aws_security_group_rule" "egress" {
  type = "egress"
  protocol = "all"
  from_port = 0
  to_port = 65535
  description = "Allows egress traffic anywhere."

  security_group_id = "${aws_security_group.default}"
}

resource "aws_security_group" "https" {
  name = "https"
  description = "Allow HTTPS traffic"
  vpc_id = "${aws_default_vpc.default}"

  tags = {
    Name = "https"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_security_group_rule" "https" {
  type = "ingress"
  protocol = "tcp"
  from_port = 443
  to_port = 443
  description = "Allows external traffic to HTTPS."

  security_group_id = "${aws_security_group.https}"
}