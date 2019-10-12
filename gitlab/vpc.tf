### Data Sources ##############################################################

### Resources #################################################################

resource "aws_vpc" "main" {
  cidr_block  = "10.0.0.0/16"

  tags = {
    Name      = "gitlab-main"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id  = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab-main"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_route_table" "public" {
  vpc_id  = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab-public"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_route" "public-wan" {
  route_table_id          = "${aws_route_table.public.id}"
  destination_cidr_block  = "0.0.0.0/0"
  gateway_id              = "${aws_internet_gateway.main.id}"
}

resource "aws_subnet" "public" {
  cidr_block  = "10.0.0.0/24"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab-public"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id       = "${aws_subnet.public.id}"
  route_table_id  = "${aws_route_table.public.id}"
}

resource "aws_eip" "nat-gw" {
  vpc = true

  tags = {
    Name = "nat-gw"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = "${aws_eip.nat-gw.id}"
  subnet_id = "${aws_subnet.public.id}"

  tags = {
    Name = "nat-gw"
    Owner = "operations-program"
    ManagedBy = "terraform"
    TFRepo = "${var.repository}"
  }

  depends_on = ["aws_internet_gateway.main"]
}

resource "aws_subnet" "runners" {
  cidr_block  = "10.0.1.0/24"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab-runners"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_route_table" "private" {
  vpc_id  = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab-private"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_route" "private-wan" {
  route_table_id          = "${aws_route_table.private.id}"
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${aws_nat_gateway.main.id}"
}

resource "aws_main_route_table_association" "main" {
  vpc_id          = "${aws_vpc.main.id}"
  route_table_id  = "${aws_route_table.private.id}"
}

resource "aws_security_group" "gitlab" {
  name                    = "gitlab"
  description             = "Allow public traffic to GitLab instances."
  revoke_rules_on_delete  = true
  vpc_id                  = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_security_group_rule" "public-icmp" {
  type        = "ingress"
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 254
  description = "Allows public ICMP traffic (all types) from any source."

  security_group_id = "${aws_security_group.gitlab.id}"
}

resource "aws_security_group_rule" "public-http" {
  type        = "ingress"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 80
  to_port     = 80
  description = "Allows public HTTP traffic from any source."

  security_group_id = "${aws_security_group.gitlab.id}"
}

resource "aws_security_group_rule" "public-https" {
  type        = "ingress"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 443
  to_port     = 443
  description = "Allows public HTTPS traffic from any source."

  security_group_id = "${aws_security_group.gitlab.id}"
}

resource "aws_security_group_rule" "public-ssh" {
  type        = "ingress"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 22
  to_port     = 22
  description = "Allows public SSH traffic from any source."

  security_group_id = "${aws_security_group.gitlab.id}"
}

resource "aws_security_group" "gitlab-runner" {
  name                    = "gitlab-runner"
  description             = "Allow management traffic to GitLab runner instances."
  revoke_rules_on_delete  = true
  vpc_id                  = "${aws_vpc.main.id}"

  tags = {
    Name      = "gitlab-runner"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_security_group_rule" "internal-ssh" {
  type        = "ingress"
  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  description = "Allows internal SSH traffic from the SSH bastion host."

  source_security_group_id  = "${aws_security_group.ssh-bastion.id}"
  
  security_group_id = "${aws_security_group.gitlab-runner.id}"
}

resource "aws_security_group" "ssh-bastion" {
  name                    = "ssh-bastion"
  description             = "Allow public traffic to SSH bastion host on non-standard port."
  revoke_rules_on_delete  = true
  vpc_id                  = "${aws_vpc.main.id}"

  tags = {
    Name      = "ssh-bastion"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_security_group_rule" "public-ssh-alternate" {
  type        = "ingress"
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 65432
  to_port     = 65432
  description = "Allows public SSH traffic from any source to a non-standard port."

  security_group_id = "${aws_security_group.ssh-bastion.id}"
}

resource "aws_security_group" "default-out" {
  name                    = "default-out"
  description             = "Allow communication with the public internet."
  revoke_rules_on_delete  = true
  vpc_id                  = "${aws_vpc.main.id}"

  tags = {
    Name      = "ssh-bastion"
    Owner     = "operations-program"
    ManagedBy = "terraform"
    TFRepo    = "${var.repository}"
  }
}

resource "aws_security_group_rule" "public-egress-all" {
  type        = "egress"
  protocol    = "all"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 65535
  description = "Allows all traffic of any type out to any destination."

  security_group_id = "${aws_security_group.default-out.id}"
}
