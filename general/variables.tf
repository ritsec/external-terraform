# Link to the repository that was used to configure this GitLab instance.
variable "repository" {
  default = "https://gitlab.ritsec.cloud/operations-program/external-terraform"
}

variable "prevent-termination" {
  default = false
}