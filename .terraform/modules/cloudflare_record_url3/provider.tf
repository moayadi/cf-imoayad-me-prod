terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.14.0"
    }
  }
}

provider "cloudflare" {
  # Configuration options
}