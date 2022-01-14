locals {
  metrics = {
    "reach" = {
      label       = "Reach"
      type        = "gauge"
      description = <<-EOF
        Record of NTP packets, 377 is the value for all recent packets received. Reach is the octal representation of one byte, each bit representing an ntp packet: 1 for received, 0 for missing. Packets enter the byte in the rightmost column and move to the left as new packets are received.
      EOF
      rollup      = "max"
      aggregate   = "max"
    }
    "poll" = {
      label       = "Poll"
      type        = "gauge"
      description = <<-EOF
        Polling interval. Note that remotes may have different intervals, so this makes more sense when grouped by remote
      EOF
      unit        = "seconds"
      rollup      = "avg"
      aggregate   = "avg"
    }
    "offset" = {
      label       = "Offset"
      type        = "gauge"
      description = <<-EOF
        Time difference between local host and ntp server at time of polling
      EOF
      unit        = "seconds"
      rollup      = "avg"
      aggregate   = "avg"
    }
    "delay" = {
      label       = "Delay"
      type        = "gauge"
      description = <<-EOF
        The roundtrip delay to ntp server
      EOF
      unit        = "milliseconds"
      rollup      = "avg"
      aggregate   = "avg"
    }
    "jitter" = {
      label       = "Jitter"
      type        = "gauge"
      description = <<-EOF
        Variance of delay to the ntp server
      EOF
      rollup      = "avg"
      aggregate   = "avg"
    }
  }
}

resource "observe_dataset" "ntpq_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "NTPq Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "ntpq"
      pick_col
        timestamp,
        remote:string(tags.remote),
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        field,
        value

      interface "metric", metric:field, value:value

      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "ntpq_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.ntpq_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
