resource "cloudflare_record" "a-record" {
  zone_id = var.zone_id
  name    = var.name
  value   = var.ip
  type    = "A"
  ttl     = 1
  proxied = true
}