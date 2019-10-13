# External Terraform

Terraform used to deploy all public cloud-based resources.

Note on general/ with vault: need to run `terraform state rm acme_certificate.vault` before destroying everything because it will yeet the account first.