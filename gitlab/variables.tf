# Link to the repository that was used to configure this GitLab instance.
variable "repository" {
  default = "https://github.com/s-newman/gitlab-config"
}

variable "prevent-termination" {
  default = true
}

variable "bastion-bootstrap-script" {
  default = <<EOF
#!/bin/bash
sed -i 's/#Port 22/Port 65432/g' /etc/ssh/sshd_config
systemctl restart sshd
EOF
}

variable "runner-bootstrap-script" {
  default = <<EOF
#!/bin/bash
echo "10.0.0.200 gitlab.ritsec.cloud" >> /etc/hosts
EOF
}
