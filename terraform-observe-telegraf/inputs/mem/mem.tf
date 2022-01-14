locals {
  metrics = {
    "active" = {
      label       = "Active"
      type        = "gauge"
      description = <<-EOF
        Total memory that has been used recently
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "available" = {
      label       = "Available"
      type        = "gauge"
      description = <<-EOF
        Total memory available for allocation
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "available_percent" = {
      label       = "Available Percent"
      type        = "gauge"
      description = <<-EOF
        Percentage of total memory available for allocation
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "avg"
    }
    "buffered" = {
      label       = "Buffered"
      type        = "gauge"
      description = <<-EOF
        Total buffered memory
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "cached" = {
      label       = "Cached"
      type        = "gauge"
      description = <<-EOF
        Total cached memory
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "commit_limit" = {
      label       = "Commit Limit"
      type        = "gauge"
      description = <<-EOF
        Total virtual memory that can be commited without having to extend the paging file
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "committed_as" = {
      label       = "Committed AS"
      type        = "gauge"
      description = <<-EOF
        Total virtual memory required to run the current processes to completion with high confidence of not running out of memory (Committed Address Space)
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "dirty" = {
      label       = "Dirty"
      type        = "gauge"
      description = <<-EOF
        Total memory that has been changed but not yet written out to disk
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "free" = {
      label       = "Free"
      type        = "gauge"
      description = <<-EOF
        Total memory that is currently unused
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "high_free" = {
      label       = "High Free"
      type        = "gauge"
      description = <<-EOF
        Free memory that is outside of the kernel's addressable space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "high_total" = {
      label       = "High Total"
      type        = "gauge"
      description = <<-EOF
        Total memory that is outside of the kernel's addressable space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "huge_pages_free" = {
      label       = "Huge Pages Free"
      type        = "gauge"
      description = <<-EOF
        Number of Huge Pages unused on the system
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "huge_pages_size" = {
      label       = "Huge Pages Size"
      type        = "gauge"
      description = <<-EOF
        Size of each Huge Page
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "huge_pages_total" = {
      label       = "Huge Pages Total"
      type        = "gauge"
      description = <<-EOF
        Number of Huge Pages on the system
      EOF
      rollup      = "avg"
      aggregate   = "sum"
    }
    "inactive" = {
      label       = "Inactive"
      type        = "gauge"
      description = <<-EOF
        Total memory available for reclamation
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "low_free" = {
      label       = "Low Free"
      type        = "gauge"
      description = <<-EOF
        Free memory that is inside of the kernel's addressable space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "low_total" = {
      label       = "Low Total"
      type        = "gauge"
      description = <<-EOF
        Total memory that is inside of the kernel's addressable space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "mapped" = {
      label       = "Mapped"
      type        = "gauge"
      description = <<-EOF
        Total mmapped virtual memory
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "page_tables" = {
      label       = "Page Tables"
      type        = "gauge"
      description = <<-EOF
        Total memory allocated to the lowest level of page tables
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "shared" = {
      label       = "Shared"
      type        = "gauge"
      description = <<-EOF
        Total memory used by shared memory and tmpfs
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "slab" = {
      label       = "Slab"
      type        = "gauge"
      description = <<-EOF
        Total memory used by slab memory management
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "sreclaimable" = {
      label       = "Sreclaimable"
      type        = "gauge"
      description = <<-EOF
        Total memory used by slab and available for reclamation (Slab Reclaimable)
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "sunreclaim" = {
      label       = "Sunreclaim"
      type        = "gauge"
      description = <<-EOF
        Total memory used by slab and unavailable for reclamation (Slab Unreclaim)
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "swap_cached" = {
      label       = "Swap Cached"
      type        = "gauge"
      description = <<-EOF
        Total memory cached in swap space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "swap_free" = {
      label       = "Swap Free"
      type        = "gauge"
      description = <<-EOF
        Total memory free in swap space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "swap_total" = {
      label       = "Swap Total"
      type        = "gauge"
      description = <<-EOF
        Total memory in swap space
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "total" = {
      label       = "Total"
      type        = "gauge"
      description = <<-EOF
        Total memory
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "used" = {
      label       = "Used"
      type        = "gauge"
      description = <<-EOF
        Total memory in use
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "used_percent" = {
      label       = "Used Percent"
      type        = "gauge"
      description = <<-EOF
        Percentage of total memory in use
      EOF
      unit        = "%"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "vmalloc_chunk" = {
      label       = "Vmalloc Chunk"
      type        = "gauge"
      description = <<-EOF
        Largest chunk of virtual memory allocated in bytes
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "vmalloc_total" = {
      label       = "Vmalloc Total"
      type        = "gauge"
      description = <<-EOF
        Total space available to be allocated as virtual memory
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "vmalloc_used" = {
      label       = "Vmalloc Used"
      type        = "gauge"
      description = <<-EOF
        Total space used as virtual memory
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "write_back" = {
      label       = "Write Back"
      type        = "gauge"
      description = <<-EOF
        Total amount of memory in the process of being written back to disk
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "write_back_tmp" = {
      label       = "Write Back Tmp"
      type        = "gauge"
      description = <<-EOF
        Total amount of memory used as temporary writeback buffers
      EOF
      unit        = "bytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
  }
}

resource "observe_dataset" "mem_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Mem Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "mem"
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

resource "observe_link" "mem_metrics" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.mem_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
