terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
  alias  = "iqonda"
  #profile = "iqonda"
  default_tags {
    tags = {
      Project     = "aws-spa-app"
      environment = "POC"
      Owner       = "rr"
    }
  }
}
