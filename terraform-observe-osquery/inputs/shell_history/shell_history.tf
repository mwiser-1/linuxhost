resource "observe_dataset" "shell_history" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Shell History")

  inputs = {
    "events" = var.osquery.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "shell_history"
      make_col event_timestamp:seconds(int64(log.columns.time))
      set_valid_from options(max_time_diff:${var.max_time_diff}), event_timestamp
      pick_col
        timestamp:event_timestamp,
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        uid:string(log.columns.uid),
        gid:string(log.columns.gid),
        history_file:string(log.columns.history_file),
        shell:string(log.columns.shell),
        command:string(log.columns.command),
        directory:string(log.columns.directory)
    EOF
  }
}

resource "observe_link" "shell_history" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.shell_history.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
