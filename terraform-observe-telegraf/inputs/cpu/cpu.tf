locals {
  default_metrics = {
    "usage_user" = {
      label       = "Usage User"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU is used by users
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_system" = {
      label       = "Usage System"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU is used by the system
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_steal" = {
      label       = "Usage Steal"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this virtual CPU is waiting on the hypervisor for a real CPU
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_softirq" = {
      label       = "Usage Soft IRQ"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent running SoftIRQs. SoftIRQs speed up the critical part of hardware interrupts by transferring state (like memory) from the hardware with other hardware interrupts off, then processing at the next highest priority the actual request with hardware interrupts on
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_nice" = {
      label       = "Usage Nice"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent running processes executed below normal priority
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_irq" = {
      label       = "Usage IRQ"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent running interrupt requests
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_iowait" = {
      label       = "Usage I/O Wait"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent waiting for I/O operations to complete
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "cpu_utilization" = {
      label       = "CPU Utilization"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent performing various activities and not waiting on I/O operations (aka. 100-idle)
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_idle" = {
      label       = "Usage Idle"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent with an empty processing queue and not waiting on I/O operations
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_guest_nice" = {
      label       = "Usage Guest Nice"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent running processes below normal priority as a virtual CPU for a guest operating system
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "usage_guest" = {
      label       = "Usage Guest"
      type        = "gauge"
      description = <<-EOF
        Percentage of time this CPU spent running as a virtual CPU for a guest operating system
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
  }
  host = {
    "linux_metrics" = {}
    "windows_metrics" = {
      # Windows Metric Definitions Begin Here
      "Percent_Processor_Time" = {
        label       = "Percent Processor Time"
        type        = "gauge"
        description = <<-EOF
          Processor usage, alternative to native, reports on a per core.
          The percentage of total elapsed time that the processor was busy executing.
        EOF
        unit        = "%"
        rollup      = "avg"
        aggregate   = "sum"
      }
      "Percent_User_Time" = {
        label       = "Percent User Time"
        type        = "gauge"
        description = <<-EOF
          Processor user usage, alternative to native, reports on a per core.\n
          The percentage of elapsed time the processor spent executing in user mode.
        EOF
        unit        = "%"
        rollup      = "avg"
        aggregate   = "sum"
      }
      "Percent_DPC_Time" = {
        label       = "Percent DPC Time"
        type        = "gauge"
        description = <<-EOF
          Processor deferred procedure calls usage, alternative to native, reports on a per core.
        EOF
        unit        = "%"
        rollup      = "avg"
        aggregate   = "sum"
      }
      "Percent_Idle_Time" = {
        label       = "Percent Idle Time"
        type        = "gauge"
        description = <<-EOF
          Processor idle time, alternative to native, reports on a per core.\n
          Idle process is indicative of the amount of CPU time that is not needed or wanted by any other threads in the system.
        EOF
        unit        = "%"
        rollup      = "avg"
        aggregate   = "sum"
      }
      "Percent_Privileged_Time" = {
        label       = "Percent Privileged Time"
        type        = "gauge"
        description = <<-EOF
          Processor privileged time, alternative to native, reports on a per core.\n
          The percentage of elapsed time that the process threads spent executing code in privileged mode.
        EOF
        unit        = "%"
        rollup      = "avg"
        aggregate   = "sum"
      }
      "Percent_Interrupt_Time" = {
        label       = "Percent Interrupt Time"
        type        = "cumulativeCounter"
        description = <<-EOF
          Processor interrupt time, alternative to native, reports on a per core.\n
          The amount of time since the system was last started, in 100-nanosecond intervals.
        EOF
        unit        = "%"
        rollup      = "avg"
        aggregate   = "sum"
      }
    }
    "macos_metrics" = {}
  }
  host_metrics   = { for k, v in var.host_os_flags : "${v}_metrics" => local.host["${v}_metrics"] }
  merged_metrics = [for k, v in local.host_metrics : v]

  metrics = {
    for k, v in merge(local.default_metrics, local.merged_metrics...) : k => v
  }
}

resource "observe_dataset" "cpu_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "CPU Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    alias = "calculate_cpu_utilization"
    pipeline = <<-EOF
      filter contains(name, "cpu")
      filter field="usage_idle"
      make_col value:100-value
      make_col field:"cpu_utilization"
      pick_col
        timestamp,
        cpu:string(tags.cpu),
        ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
        field,
        value
    EOF
  }
  stage {
    input    = "events"
    pipeline = <<-EOF
      filter contains(name, "cpu")
      pick_col
        timestamp,
        cpu:string(tags.cpu),
        host:string(tags.host),
        datacenter:string(tags.datacenter),
        field,
        value
      union @calculate_cpu_utilization
      interface "metric", metric:field, value:value
      ${join("\n\n", [for metric, options in local.metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
  EOF    
 }
}



resource "observe_link" "cpu_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.cpu_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
