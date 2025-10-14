terraform {

  required_version = ">= 1.5.7"

  cloud {
    organization = "oak-national-academy"
    workspaces {
      tags = ["repo:oak-robots-txt", "config:project"]
    }
  }
}