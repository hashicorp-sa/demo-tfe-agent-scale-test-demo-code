resource "time_sleep" "wait_30_seconds" { 
  create_duration = "30s"
  triggers = {
    time_rotating = timestamp()
  }
}

resource "random_string" "random" {
  count            = 10
  length           = 1000
  special          = true
}

output "name" {
  value = random_string.random[*].result
}