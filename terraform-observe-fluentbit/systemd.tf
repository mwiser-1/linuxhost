resource "observe_dataset" "systemd_events" {
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Systemd")
  icon_url    = "diff-files"
  description = "Systemd Log Events"

  inputs = {
    "event" = observe_dataset.events[0].oid
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      filter string(inputType) = "/fluentbit/systemd"
      pick_col
        timestamp,
        message:string(event['MESSAGE']),
        priority:int64(event['PRIORITY']),
        facility:string(event['SYSLOG_FACILITY']),
        cmdline:string(event['_CMDLINE']),
        comm:string(event['_COMM']),
        exe:string(event['_EXE']),
        gid:string(event['_GID']),
        uid:string(event['_UID']),
        pid:string(event['_PID']),
        codeFile:string(event['CODE_FILE']),
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        event
      colshow event:false
    EOF
  }
}
resource "observe_link" "systemd_events" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.systemd_events.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
} 
