# Link to the repository that was used to configure this GitLab instance.
variable "repository" {
  default = "https://gitlab.ritsec.cloud/operations-program/external-terraform"
}

variable "prevent-termination" {
  default = true
}

variable "bootstrap-script" {
  default = <<EOF
#!/bin/bash
sed -i 's/#Port 22/Port 65432/g' /etc/ssh/sshd_config
systemctl restart sshd
EOF
}