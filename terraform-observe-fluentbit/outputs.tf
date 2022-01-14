output "events" {
  # this works around "var.events_dataset is null" error, but there's probably a more elegant way of doing this
  value = try(local.create_events_dataset ? observe_dataset.events[0] : var.events_dataset, observe_dataset.events[0])
}

output "log_file" {
  value = observe_dataset.log_file
}
output "systemd" {
  value = observe_dataset.systemd_events
}
