locals {
  metrics = {
    "total" = {
      label       = "Total"
      type        = "gauge"
      description = <<-EOF
        Total in all states
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "stopped" = {
      label       = "Stopped"
      type        = "gauge"
      description = <<-EOF
        Stopped via signal
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "sleeping" = {
      label       = "Sleeping"
      type        = "gauge"
      description = <<-EOF
        Sleeping in an interruptable wait
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "zombies" = {
      label       = "Zombies"
      type        = "gauge"
      description = <<-EOF
        Child processes which remain after completion to allow the parent process access to the exit status
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "unknown" = {
      label       = "Unknown"
      type        = "gauge"
      description = <<-EOF
        Unknown state
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "total_threads" = {
      label       = "Total Threads"
      type        = "gauge"
      description = <<-EOF
        Total Threads among all processes
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "running" = {
      label       = "Running"
      type        = "gauge"
      description = <<-EOF
        Total Running
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "paging" = {
      label       = "Paging"
      type        = "gauge"
      description = <<-EOF
        Total processes paging some of their memory to disk to free up space for more active processes
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "idle" = {
      label       = "Idle"
      type        = "gauge"
      description = <<-EOF
        Total sleeping uninterruptable kernel processes
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "dead" = {
      label       = "Dead"
      type        = "gauge"
      description = <<-EOF
        Total processes that have completed but not yet cleaned up. According to ps this should rarely be anything over than 0
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "processes_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Processes Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "processes"
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

resource "observe_link" "processes_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.processes_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
