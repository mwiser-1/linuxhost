resource "observe_dataset" "taillog_events" {
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Logs")
  icon_url    = "diff-files"
  description = "Tail Log Events"

  inputs = {
    "events" = observe_dataset.events[0].oid
  }

  // make one stage per parse_type, then union them all together at the end
  dynamic "stage" {
    for_each = var.file_formats

    content {
      input    = "events"
      alias    = stage.key
      pipeline = <<-EOF
        filter string(inputType) = "/fluentbit/tail"
        make_col 
          fluentTimestamp:from_nanoseconds(int64(event.fluentTimestamp))
        set_valid_from fluentTimestamp
        make_col
          host:string(tags.host),
          datacenter:string(tags.datacenter)
        pick_col
          timestamp:fluentTimestamp,
          message:string(event["log"]),
          host,
          datacenter,
          path:string(event["path"])
      EOF
    }
  }
}

resource "observe_link" "taillog_events" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.taillog_events.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
