resource "random_string" "random" {
  count            = 1000
  length           = 16
  special          = true
}

output "name" {
  value = random_string.random[*].result
}