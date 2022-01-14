locals {
  metrics = {
    "bytes_recv" = {
      label       = "Bytes Recv"
      type        = "gauge"
      description = <<-EOF
        Bytes received
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "bytes_sent" = {
      label       = "Bytes Sent"
      type        = "gauge"
      description = <<-EOF
        Bytes transmitted
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "bytes_total" = {
      label       = "Bytes Total (In and Out)"
      type        = "gauge"
      description = <<-EOF
        Bytes transmitted
      EOF
      unit        = "bytes"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "packets_recv" = {
      label       = "Packets Recv"
      type        = "gauge"
      description = <<-EOF
        Packets received
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
    "packets_sent" = {
      label       = "Packets Sent"
      type        = "gauge"
      description = <<-EOF
        Packets transmitted
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
    "packets_total" = {
      label       = "Packets Total (In and Out)"
      type        = "gauge"
      description = <<-EOF
        Packets transmitted
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
    "drop_in" = {
      label       = "Drop In"
      type        = "gauge"
      description = <<-EOF
        Packets recieved which were dropped by the interface
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
    "drop_out" = {
      label       = "Drop Out"
      type        = "gauge"
      description = <<-EOF
        Packets transmitted which were dropped by the interface
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
    "err_in" = {
      label       = "Err In"
      type        = "gauge"
      description = <<-EOF
        Receive errors which were detected by the interface
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
    "err_out" = {
      label       = "Err Out"
      type        = "gauge"
      description = <<-EOF
        Transmit errors which were detected by the interface
      EOF
      unit        = ""
      rollup      = "rate"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "net_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Net Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }
  stage {
    input    = "events"
    alias    = "net_metrics"
    pipeline = <<-EOF
      filter contains(name, "net")
      pick_col
        timestamp,
        interface:string(tags.interface),
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        field,
        value
    EOF
  }
  stage {
    alias    = "calculated_bytes_total"
    pipeline = <<-EOF
      filter contains(field,"bytes_")
      make_col 
        m1: float64(case(field="bytes_sent",value, true, float64_null()))
      make_col 
        m2: float64(case(field="bytes_recv",value, true, float64_null())) 
      timestats m1: any_not_null(m1), m2: any_not_null(m2), group_by(datacenter,host,interface) 
      make_col 
        value: float64(m1 + m2),
        field:"bytes_total",
        name:"net"
      pick_col
         timestamp,
         interface,
         host,
         datacenter,
         field,
         value
    EOF
  }
  stage {
    input    = "net_metrics"
    alias    = "calculated_packets_total"
    pipeline = <<-EOF
      filter contains(field,"packets_")
      make_col 
        m1: float64(case(field="packets_sent",value, true, float64_null()))
      make_col 
        m2: float64(case(field="packets_recv",value, true, float64_null())) 
      timestats m1: any_not_null(m1), m2: any_not_null(m2), group_by(datacenter,host,interface) 
      make_col 
        value: float64(m1 + m2),
        field:"packets_total",
        name:"net"
      pick_col
         timestamp,
         interface,
         host,
         datacenter,
         field,
         value
    EOF
  }
  stage {
    input    = "net_metrics"
    pipeline = <<-EOF
      union @calculated_packets_total
      union @calculated_bytes_total
      filter not interface = "all"

      interface "metric", metric:field, value:value

      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "net_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.net_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
