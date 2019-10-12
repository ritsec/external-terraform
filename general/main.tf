terraform {
  backend "s3" {
    bucket	= "ritsec-tf-remotestate"
    key     = "general"
    region	= "us-east-2"
    profile	= "ritsec"
  }
}

provider "aws" {
  region	= "us-east-1"
  profile	= "ritsec"
}

provider "acme" {
  server_url = "https://acme-v01.api.letsencrypt.org/directory"
}