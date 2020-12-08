terraform {
  backend "remote" {
    organization = "moayadi"

    workspaces {
      prefix = "cf-imoayad-me-"
    }
  }
}