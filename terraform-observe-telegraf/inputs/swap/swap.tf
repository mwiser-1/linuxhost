locals {
  metrics = {
    "total" = {
      label       = "Total"
      type        = "gauge"
      description = <<-EOF
        Total swap memory
      EOF
      unit        = "bytes"
      rollup      = "sum"
      aggregate   = "sum"
    }
    "free" = {
      label       = "Free"
      type        = "gauge"
      description = <<-EOF
        Free swap memory
      EOF
      unit        = "bytes"
      rollup      = "sum"
      aggregate   = "sum"
    }
    "used" = {
      label       = "Used"
      type        = "gauge"
      description = <<-EOF
        Used swap memory
      EOF
      unit        = "bytes"
      rollup      = "sum"
      aggregate   = "sum"
    }
    "used_percent" = {
      label       = "Used Percent"
      type        = "gauge"
      description = <<-EOF
        Percentage of swap memory used
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "in" = {
      label       = "In"
      type        = "gauge"
      description = <<-EOF
        Total data swapped in since last boot calculated from page number
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "out" = {
      label       = "Out"
      type        = "gauge"
      description = <<-EOF
        Total data swapped out since last boot calculated from page number
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "swap_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Swap Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "swap"
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

resource "observe_link" "swap_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.swap_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
