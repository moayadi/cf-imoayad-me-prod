variable "domain" {
  default = "imoayad.me"
}

variable "username" {
  type = string
}

variable "apikey" {
  type = string
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
