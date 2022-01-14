locals {
  metrics = {
    "memory_usage" = {
      label       = "Memory Usage"
      type        = "gauge"
      description = <<-EOF
        Percentage of memory being used by process
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
   "cpu_usage" = {
      label       = "CPU Usage"
      type        = "gauge"
      description = <<-EOF
        Percent of CPU core used by process
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    } 
  }
}

resource "observe_dataset" "processlist_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "ProcessList Metrics")
  icon_url  = "chromatography"

  description = <<-EOF
    This dataset contains raw telegraf events, from which metric datasets can
    be derived.
  EOF

  inputs = {
    "observation" = data.observe_dataset.observation.oid
  }

  stage {
    input    = "observation"
    pipeline = <<-EOF
      filter OBSERVATION_KIND = "http" and string(EXTRA.path) = "/telegraf" and FIELDS.name="procstat"
      make_col 
        fields:FIELDS.fields,
        name:string(FIELDS.name),
        tags:FIELDS.tags
      make_col 
        process_name:string(tags.process_name),
        user:string(tags.user),
        exe:string(tags.exe),
        host:string(tags.host),
        datacenter:string(tags.datacenter)
      make_col 
        pid:int64(fields.pid),
        threadcount:int64(fields.pgrep_serviceprocess_num_threads),
        memory_usage:float64(fields.pgrep_serviceprocess_memory_usage),
        memory_swap:int64(fields.pgrep_serviceprocess_memory_swap),
        cpu_usage:int64(fields.pgrep_serviceprocess_cpu_usage)
      pick_col 
        BUNDLE_TIMESTAMP,
        host,
        pid,
        datacenter,
        process_name,
        threadcount,
        memory_usage,
        memory_swap,
        cpu_usage
      filter memory_usage>0  
      make_col 
        metrics:makeobject("memory_usage":memory_usage, 
        "cpu_usage":cpu_usage, 
        "thread_count":threadcount)
      flatten_leaves metrics
      pick_col
        valid_from:BUNDLE_TIMESTAMP,
        pid, process_name, host, datacenter,
        metric_name:string(_c_metrics_path), metric_value:float64(_c_metrics_value)
      interface "metric", metric:metric_name, value:metric_value
      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "process_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.processlist_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}



  