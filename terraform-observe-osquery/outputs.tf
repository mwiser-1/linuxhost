output "events" {
  # this works around "var.events_dataset is null" error, but there's probably a more elegant way of doing this
  value = try(local.create_events_dataset ? observe_dataset.events[0] : var.events_dataset, observe_dataset.events[0])
}

output "host" {
  value = observe_dataset.host
}

output "volume" {
  value = observe_dataset.volume
}

output "interface" {
  value = observe_dataset.interface
}

output "users" {
  value = observe_dataset.users
}
/*
output "logged_in_users" {
  value = contains(var.create_resources, "users") ? observe_dataset.logged_in_users[0] : null
}*/
