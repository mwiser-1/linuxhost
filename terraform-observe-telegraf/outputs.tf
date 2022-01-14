output "events" {
  # this works around "var.events_dataset is null" error, but there's probably a more elegant way of doing this
  value = try(local.create_events_dataset ? observe_dataset.events[0] : var.events_dataset, observe_dataset.events[0])
}

