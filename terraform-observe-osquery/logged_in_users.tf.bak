resource "observe_dataset" "logged_in_users" {
  count       = contains(var.create_resources, "users") ? 1 : 0
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Logged In Users")
  icon_url    = "server"
  description = "Logged In Users resource generated from OSQuery logged_in_users and logged_in_users_snapshot events"

  inputs = {
    "event" = observe_dataset.events[0].oid
    "users" = observe_dataset.users[0].oid
  }

  stage {
    input    = "event"
    alias    = "snapshot"
    pipeline = <<-EOF
      filter name = "logged_in_users_snapshot"
      make_col time:seconds(int64(log.unixTime))
      flatten_single log.snapshot
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))},
        username:string(@."_c_log_snapshot_value".user),
        action:string("added"),
        pid:int64(@."_c_log_snapshot_value".pid),
        tty:string(@."_c_log_snapshot_value".tty),
        type:string(@."_c_log_snapshot_value".type)
    EOF
  }

  stage {
    input    = "event"
    pipeline = <<-EOF
      filter name = "logged_in_users"
      make_col
        ${indent(2, join(",\n", [for tag in var.extract_tags : format("%s:string(tags.%s)", tag, tag)]))},
        username:string(log.columns.user),
        action:string(log.action),
        time:seconds(int64(log.columns.time)),
        pid:int64(log.columns.pid),
        tty:string(log.columns.tty),
        type:string(log.columns.type)
      union @snapshot
      set_valid_from options(max_time_diff:${var.max_time_diff}), time
      lookup username=@users.username, datacenter=@users.datacenter, host=@users.host, uid:@users.uid
      filter not isnull(uid)
      make_resource options(expiry:10m),
        timestamp:time,
        action,
        uid,
        type,
        primarykey(${join(", ", [for tag in var.extract_tags : tag])}, username)
      set_label username
    EOF
  }
}

resource "observe_link" "logged_in_users" {
  for_each = contains(var.create_resources, "users") ? {
    "host" : {
      "target" : observe_dataset.users[0].oid,
      "fields" : flatten([[for tag in var.extract_tags : format("%s", tag)], ["uid"]]),
    }
  } : {}

  workspace = var.workspace.oid
  source    = observe_dataset.logged_in_users[0].oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
