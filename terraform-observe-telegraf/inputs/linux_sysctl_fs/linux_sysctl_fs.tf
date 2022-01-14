locals {
  metrics = {
    "file-max" = {
      label       = "File Max"
      type        = "gauge"
      description = <<-EOF
        Maximum file handles allocatable on this system
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "file-nr" = {
      label       = "File NR"
      type        = "gauge"
      description = <<-EOF
        File handles allocated on this system
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "linux_sysctl_fs_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "linux_sysctl_fs Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "linux_sysctl_fs"
      make_col
        field:replace(replace(field, "']", ""), "['", "")
      pick_col
        timestamp,
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        field,
        value

      interface "metric", metric:field, value:value

      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "linux_sysctl_fs_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.linux_sysctl_fs_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
