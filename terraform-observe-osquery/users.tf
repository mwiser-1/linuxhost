resource "observe_dataset" "users" {
  workspace   = var.workspace.oid
  name        = format(var.resource_name_format, "Users")
  icon_url    = "server"
  description = "Users resource generated from OSQuery users_snapshot events"

  inputs = {
    "event" = observe_dataset.events[0].oid
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      filter name = "users_snapshot"
      flatten_single log.snapshot
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))},
        uid:string(@."_c_log_snapshot_value".uid),
        gid:string(@."_c_log_snapshot_value".gid),
        uid_signed:string(@."_c_log_snapshot_value".uid_signed),
        gid_signed:string(@."_c_log_snapshot_value".gid_signed),
        username:string(@."_c_log_snapshot_value".username),
        description:string(@."_c_log_snapshot_value".description),
        directory:string(@."_c_log_snapshot_value".directory),
        shell:string(@."_c_log_snapshot_value".shell),
        uuid:string(@."_c_log_snapshot_value".uuid)
      make_resource options(expiry:5m),
        gid,
        uid_signed,
        gid_signed,
        username,
        description,
        directory,
        shell,
        uuid,
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, uid)
      set_label username
    EOF
  }
}

resource "observe_link" "users" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.users.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
