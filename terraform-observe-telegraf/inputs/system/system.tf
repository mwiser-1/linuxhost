locals {
  metrics = {
    "n_users" = {
      label       = "N Users"
      type        = "gauge"
      description = <<-EOF
        Number of users currently logged in
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "n_cpus" = {
      label       = "N CPUs"
      type        = "gauge"
      description = <<-EOF
        Number of cpus on the system
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "load1" = {
      label       = "Load1"
      type        = "gauge"
      description = <<-EOF
        Load average over the last 1 minute
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "load5" = {
      label       = "Load5"
      type        = "gauge"
      description = <<-EOF
        Load average over the last 5 minutes
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "load15" = {
      label       = "Load15"
      type        = "gauge"
      description = <<-EOF
        Load average over the last 15 minutes
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "uptime" = {
      label       = "Uptime"
      type        = "gauge"
      description = <<-EOF
        System uptime
      EOF
      unit        = "second"
      rollup      = "avg"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "system_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "System Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "system"
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

resource "observe_link" "system_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.system_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
