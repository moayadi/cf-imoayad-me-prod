terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "2.10.1"
    }
  }
}

provider "cloudflare" {
  email = "moayad.ismail@gmail.com"
  api_key = "b59244cd3defbaa1dd8b174cea2a106abd346"
}

variable "domain" {
  default = "imoayad.me"
}

resource "cloudflare_zone" "imoayad" {
    zone = var.domain
}

resource "cloudflare_record" "vaultserver" {
  zone_id = cloudflare_zone.imoayad.id
  name    = "vault.imoayad.me"
  value   = "34.227.192.182"
  type    = "A"
  ttl     = 1
  proxied = true
}
