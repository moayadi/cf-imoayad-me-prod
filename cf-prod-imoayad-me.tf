provider "cloudflare" {


}

data "cloudflare_zones" "zone" {
  filter {
    name = var.Domain
  }
  
}

module "cloudflare_record_url1" {
  source  = "app.terraform.io/moayadi/acrecord/cloudflare"
  version = "1.0.2"
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = var.configuration.prod.url1.name
  ip      = var.configuration.prod.url1.ip
  proxied = true

}

module "cloudflare_record_url2" {
  source  = "app.terraform.io/moayadi/acrecord/cloudflare"
  version = "1.0.2"
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = var.configuration.prod.url2.name
  ip      = var.configuration.prod.url2.ip
  proxied = true
}

module "cloudflare_record_url3" {
  source  = "app.terraform.io/moayadi/acrecord/cloudflare"
  version = "1.0.2"
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = var.configuration.prod.url3.name
  ip      = var.configuration.prod.url3.ip
  proxied = true
}


output "zone_id" {
  value = data.cloudflare_zones.zone.zones[0].id
}