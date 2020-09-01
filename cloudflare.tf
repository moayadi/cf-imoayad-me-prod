variable "domain" {
  default = "imoayad.me"
}

variable "username" {
  type = string
}

variable "apikey" {
  type = string
}

# resource "cloudflare_zone" "imoayad" {
#     zone = var.domain
# }

data "cloudflare_zones" "zone" {
  filter {
    name = "imoayad.me"
  }
  
}

resource "cloudflare_record" "vaultserver" {
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = "vault.imoayad.me"
  value   = "34.227.192.182"
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "vaultserver1" {
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = "vault1.imoayad.me"
  value   = "34.227.192.182"
  type    = "A"
  ttl     = 1
  proxied = true
}

# resource "cloudflare_record" "vaultserver2" {
#   zone_id = data.cloudflare_zones.zone.zones[0].id
#   name    = "vault2.imoayad.me"
#   value   = "34.227.192.182"
#   type    = "A"
#   ttl     = 1
#   proxied = false
# }
