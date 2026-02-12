terraform {
  required_version = ">= 1.0"

  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">= 1.212.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }
}