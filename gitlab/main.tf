terraform {
  backend "s3" {
    bucket	= "ritsec-tf-remotestate"
    key     = "gitlab"
    region	= "us-east-2"
    profile	= "ritsec"
  }
}

provider "aws" {
  region	= "us-east-1"
  profile	= "ritsec"
}
