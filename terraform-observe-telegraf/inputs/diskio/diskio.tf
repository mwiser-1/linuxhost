locals {
  metrics = {
    "read_bytes" = {
      label       = "Read Bytes"
      type        = "gauge"
      description = <<-EOF
        Total Bytes read
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "write_bytes" = {
      label       = "Write Bytes"
      type        = "gauge"
      description = <<-EOF
        Total Bytes written
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "reads" = {
      label       = "Reads"
      type        = "gauge"
      description = <<-EOF
        Total reads
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "writes" = {
      label       = "Writes"
      type        = "gauge"
      description = <<-EOF
        Total writes
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "read_time" = {
      label       = "Read Time"
      type        = "gauge"
      description = <<-EOF
        Total time reading (multiple reads add time independently)
      EOF
      unit        = "milliseconds"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "write_time" = {
      label       = "Write Time"
      type        = "gauge"
      description = <<-EOF
        Total time writing (multiple writes add time independently)
      EOF
      unit        = "milliseconds"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "merged_reads" = {
      label       = "Merged Reads"
      type        = "gauge"
      description = <<-EOF
        Total number of adjacent reads merged together on this device for efficiency
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "merged_writes" = {
      label       = "Merged Writes"
      type        = "gauge"
      description = <<-EOF
        Total number of adjacent writes merged together on this device for efficiency
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "io_time" = {
      label       = "I/O Time"
      type        = "gauge"
      description = <<-EOF
        Total time any I/O requests have waited on this device
      EOF
      unit        = "milliseconds"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "weighted_io_time" = {
      label       = "Weighted I/O Time"
      type        = "gauge"
      description = <<-EOF
        Total request time I/O requests have waited on this device (multiple requests add time independently)
      EOF
      unit        = "milliseconds"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "iops_in_progress" = {
      label       = "IOPS in Progress"
      type        = "gauge"
      description = <<-EOF
        Total IOPS pending and waiting for completion
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "diskio_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Disk IO Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "diskio"
      make_col raw_device:regex_match(string(tags.name), /^[a-zA-Z]+$/)
      filter ${var.raw_devices ? "" : "not"} raw_device
      pick_col
        timestamp,
        device:string(tags.name),
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        field,
        value

      interface "metric", metric:field, value:value

      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "diskio_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.diskio_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
