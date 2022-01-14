locals {
  metrics = {
    "free" = {
      label       = "Free"
      type        = "gauge"
      description = <<-EOF
        Total Bytes free
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "used" = {
      label       = "Used"
      type        = "gauge"
      description = <<-EOF
        Total Bytes used
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "total" = {
      label       = "Total"
      type        = "gauge"
      description = <<-EOF
        Total Bytes
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "used_percent" = {
      label       = "Used Percent (Max)"
      type        = "gauge"
      description = <<-EOF
        Maximum Percentage of a volume or mount point used over rollup timeframe. This metric acts similar to an avg aggregation, however when watching longer timeframes the
        average can be misleading and does not detect filesystems that are filling up quickly.
      EOF
      unit        = "%"
      rollup      = "max"
      aggregate   = "avg"
    }
    "inodes free" = {
      label       = "Inodes Free"
      type        = "gauge"
      description = <<-EOF
        Total Inodes free
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "inodes_used" = {
      label       = "Inodes Used"
      type        = "gauge"
      description = <<-EOF
        Total Inodes used
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "inodes_total" = {
      label       = "Inodes Total"
      type        = "gauge"
      description = <<-EOF
        Total Inodes
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "disk_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Disk Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "disk"
      make_col raw_device:regex_match(string(tags.name), /^[a-zA-Z]+$/)
      filter ${var.raw_devices ? "" : "not"} raw_device
      pick_col
        timestamp,
        volume:string(tags.device),
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        field,
        value

      interface "metric", metric:field, value:value

      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "disk_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.disk_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
