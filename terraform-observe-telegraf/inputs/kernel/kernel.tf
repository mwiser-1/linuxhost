locals {
  metrics = {
    "processes_forked" = {
      label       = "Processes Forked"
      type        = "gauge"
      description = <<-EOF
        Total Processes forked since boot
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "interrupts" = {
      label       = "Interrupts"
      type        = "gauge"
      description = <<-EOF
        Total Interrupts serviced since boot time
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "entropy_avail" = {
      label       = "Entropy Avail"
      type        = "gauge"
      description = <<-EOF
        Total entropy available to the system for generating random numbers through /dev/random. When this hits zero these processes must wait for more entropy generating events to come in to refill the bucket
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "context_switches" = {
      label       = "Context Switches"
      type        = "gauge"
      description = <<-EOF
        Total Context switches the system underwent
      EOF
      rollup      = "rate"
      aggregate   = "sum"
    }
    "boot_time" = {
      label       = "Boot Time"
      type        = "gauge"
      description = <<-EOF
        Seconds after the epoch (1970-01-01 00:00:00 +0000) this system booted up
      EOF
      unit        = "second"
      rollup      = "avg"
      aggregate   = "avg"
    }
  }
}

resource "observe_dataset" "kernel_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Kernel Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "kernel"
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

resource "observe_link" "kernel_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.kernel_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
