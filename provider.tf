terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.10.1"
    }
  }
}

provider "cloudflare" {
  email = var.username
  api_key = var.apikey
}

