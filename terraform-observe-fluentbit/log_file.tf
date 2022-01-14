resource "observe_dataset" "log_file" {
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Log File")
  icon_url    = "audio-file"
  description = "Tailed Log File"

  inputs = {
    "events" = observe_dataset.events[0].oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter string(inputType) = "/fluentbit/tail"
      make_col
        path:string(event["path"]),
        host:string(tags.host),
        datacenter:string(tags.datacenter)
      make_resource options (expiry:30s),
         primarykey(host, datacenter, path)
      set_label path
    EOF
  }
}

resource "observe_link" "log_file" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.log_file.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
} 
