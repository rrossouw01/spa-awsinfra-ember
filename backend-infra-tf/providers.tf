terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  #alias   = "usergroup"
  #profile = "admin-usergroup"
  default_tags {
    tags = {
      #iac-repository        = var.repo_full_name ## GITHUB_REPOSITORY
      #iac-repository-branch = var.repo_branch    ## GITHUB_REF_NAME
      #iac-repository-commit    = var.repo_commit    ## GITHUB_SHA
      iac-source   = "terraform in /TANK/DATA/MyWorkDocs/iqonda/POC/spa-awsinfra-ember"
      environment  = var.environment
      tech-contact = "rrosso@iqonda.com"
      #last-updater             = var.repo_actor     ## GITHUB_ACTOR
    }
  }
}
