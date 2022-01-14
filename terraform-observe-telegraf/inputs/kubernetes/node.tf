locals {
  base_node_metrics = {
    "network_tx_bytes" = {
      label       = "Node Bytes Sent",
      type        = "cumulativeCounter",
      unit        = "bytes",
      description = "Total bytes sent",
      rollup      = "rate",
      aggregate   = "sum"
    }
    "network_rx_bytes" = {
      label       = "Node Bytes Received",
      type        = "cumulativeCounter",
      unit        = "bytes",
      description = "Total bytes received",
      rollup      = "rate",
      aggregate   = "sum"
    }
    "network_tx_errors" = {
      label       = "Node Tx Errors",
      type        = "cumulativeCounter",
      description = "Total number of transmission errors",
      rollup      = "rate",
      aggregate   = "sum"
    },
    "network_rx_errors" = {
      label       = "Node Rx Errors",
      type        = "cumulativeCounter",
      description = "Total receive error count",
      rollup      = "rate",
      aggregate   = "sum"
    }
    "cpu_usage_ratio" = {
      label       = "CPU Usage Ratio"
      type        = "gauge"
      description = "Ratio of node CPU used",
      rollup      = "avg"
      aggregate   = "avg"
    }
  }

  node_metrics = {
    for k, v in merge(local.base_node_metrics, var.extra_node_metrics) : k => v
    if((var.allowed_metrics == null ? true : contains(var.allowed_metrics, k)) && (var.ignored_metrics == null ? true : !contains(var.ignored_metrics, k)))
  }
}

resource "observe_dataset" "node_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Node Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
    "node"   = var.kubernetes.node.oid
  }

  stage {
    alias    = "usage_ratio"
    input    = "events"
    pipeline = <<-EOF
      filter name = "kubernetes_node"
      make_col
        clusterUid:string(tags.clusterUid),
        nodeName:string(tags.node_name)

      lookup clusterUid=@node.clusterUid, nodeName=@node.name,
        allocatable_cpu:@node.allocatable_cpu, allocatable_memory:@node.allocatable_memory

      filter field = "memory_usage_bytes" or field = "cpu_usage_nanocores"
      make_col value:case(
          field = "memory_usage_bytes", value/allocatable_memory,
          field = "cpu_usage_nanocores", value/allocatable_cpu/1000000000)
      make_col field:case(
          field = "memory_usage_bytes", "memory_usage_ratio",
          field = "cpu_usage_nanocores", "cpu_usage_ratio")

      pick_col
        timestamp,
        clusterUid,
        nodeName,
        field,
        value,
        tags
    EOF
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "kubernetes_node"
      pick_col
        timestamp,
        clusterUid:string(tags.clusterUid),
        nodeName:string(tags.node_name),
        field,
        value,
        tags

      union @usage_ratio

      interface "metric", metric:field, value:value
      ${join("\n\n", [for metric, options in local.node_metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "node_metrics" {
  workspace = var.workspace.oid
  source    = observe_dataset.node_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key

  for_each = {
    "Cluster" = {
      target = var.kubernetes.cluster.oid
      fields = ["clusterUid:uid"]
    }
    "Node" = {
      target = var.kubernetes.node.oid
      fields = ["clusterUid", "nodeName:name"]
    }
  }
}
