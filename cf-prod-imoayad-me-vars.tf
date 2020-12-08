#
# The name of the environment, should be set on the TFC workspace
#
variable "Environment" {
  type = string
}

variable "Domain" {
  type = string
}

#
# Contains the configuration based on the environment variable.
# The name of the environment is the key for the map see outputs.tf
# for an example of how to lookup and reference this variables :)
#
variable "configuration" {
  default = {
    dev = { # TEST VARIABLES
        url1 = {
          name = "host1.test.imoayad.me"
          ip = "34.227.192.182"
        }
        url2 = {
          name = "host2.test.imoayad.me"
          ip = "34.227.192.182"
        }
        url3 = {
          name = "host3.test.imoayad.me"
          ip = "34.227.192.182"
        }
    }
    prod = { # STAGING VARIABLES
        url1 = {
          name = "host1.prod.imoayad.me"
          ip = "34.227.192.186"
        }
        url2 = {
          name = "host2.prod.imoayad.me"
          ip = "34.227.192.182"
        }
        url3 = {
          name = "host3.prod.imoayad.me"
          ip = "34.227.192.182"
        }
    }
  }
}
