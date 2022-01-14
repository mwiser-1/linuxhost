locals {
  pod_volume_metrics_facet = {
    "Cluster"   = "Namespace"
    "Namespace" = "Pod"
    "Node"      = "Pod"
    "Pod"       = "Volume"
  }

  base_pod_volume_metrics = {
    "capacity_bytes" = {
      label       = "Capacity Bytes"
      type        = "gauge"
      unit        = "bytes"
      description = "Total capacity (bytes) of the filesystems underlying storage"
      rollup      = "avg"
      aggregate   = "sum"
    }

    "available_bytes" = {
      label       = "Available Bytes"
      type        = "gauge"
      unit        = "bytes"
      description = "Storage space available (bytes) for the filesystem"
      rollup      = "avg"
      aggregate   = "sum"
    }

    "used_bytes" = {
      label       = "Used Bytes"
      type        = "gauge"
      unit        = "bytes"
      description = "Bytes used for a specific task on the filesystem. This may differ from the total bytes used on the filesystem and may not equal CapacityBytes - AvailableBytes"
      rollup      = "avg"
      aggregate   = "sum"
    }
  }

  pod_volume_metrics = {
    for k, v in merge(local.base_pod_volume_metrics, var.extra_pod_volume_metrics) : k => v
    if((var.allowed_metrics == null ? true : contains(var.allowed_metrics, k)) && (var.ignored_metrics == null ? true : !contains(var.ignored_metrics, k)))
  }
}

resource "observe_dataset" "pod_volume_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Volume Metrics")

  inputs = {
    "events" = var.telegraf.events.oid
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "kubernetes_pod_volume"
      pick_col
        timestamp,
        clusterUid:string(tags.clusterUid),
        namespace:string(tags.namespace),
        podName:string(tags.pod_name),
        nodeName:string(tags.node_name),
        volumeName:string(tags.volume_name),
        field,
        value,
        tags

      interface "metric", metric:field, value:value

      ${join("\n\n", [for metric, options in local.pod_volume_metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }
}

resource "observe_link" "pod_volume_metrics" {
  workspace = var.workspace.oid
  source    = observe_dataset.pod_volume_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key

  for_each = {
    "Cluster" = {
      target = var.kubernetes.cluster.oid
      fields = ["clusterUid:uid"]
    }
    "Namespace" = {
      target = var.kubernetes.namespace.oid
      fields = ["clusterUid", "namespace:name"]
    }
    "Pod" = {
      target = var.kubernetes.pod.oid
      fields = ["clusterUid", "namespace", "podName:name"]
    }
    "Node" = {
      target = var.kubernetes.node.oid
      fields = ["clusterUid", "nodeName:name"]
    }
    "Volume" = {
      target = var.kubernetes.volume.oid
      fields = ["clusterUid", "namespace", "podName", "volumeName:name"]
    }
  }
}

resource "observe_board" "pod_volume_metrics" {
  for_each = merge(
    {
      "Base" = {
        board_dataset = observe_dataset.pod_volume_metrics.oid
        type          = "set"
      }
    },
    # Inherit set board defined on metric dataset if there is a link towards a resource
    { for k, v in observe_link.pod_volume_metrics :
      format("Set_%s", k) => {
        type           = "set"
        board_dataset  = v.target
        target_dataset = v.target
        label          = k,
        src_fields     = [for field in v.fields : try(element(split(":", field), 0), field)]
        dst_fields     = [for field in v.fields : try(element(split(":", field), 1), field)]
        group_by       = [for field in v.fields : try(element(split(":", field), 0), field)]
      }
    },
    # Inherit singleton board defined on metric dataset with facet, if available
    { for k, v in observe_link.pod_volume_metrics :
      format("Singleton_%s", k) => {
        type           = "singleton"
        board_dataset  = v.target
        target_dataset = observe_link.pod_volume_metrics[local.pod_volume_metrics_facet[k]].target
        label          = local.pod_volume_metrics_facet[k]
        src_fields     = [for field in v.fields : try(element(split(":", field), 0), field)]
        dst_fields     = [for field in v.fields : try(element(split(":", field), 1), field)]
        group_by       = [for field in observe_link.pod_volume_metrics[local.pod_volume_metrics_facet[k]].fields : try(element(split(":", field), 0), field)]
      } if contains(keys(local.pod_volume_metrics_facet), k)
    },
    # Inherit singleton board defined on metric dataset in absence of available facet
    { for k, v in observe_link.pod_volume_metrics :
      format("Singleton_%s", k) => {
        type           = "singleton"
        board_dataset  = v.target
        target_dataset = v.target
        label          = k
        src_fields     = [for field in v.fields : try(element(split(":", field), 0), field)]
        dst_fields     = [for field in v.fields : try(element(split(":", field), 1), field)]
      } if !contains(keys(local.pod_volume_metrics_facet), k)
    },
  )

  dataset = each.value.board_dataset
  name    = "Pod Volume Metrics"
  type    = each.value.type
  json = templatefile("${path.module}/boards/pod_volume_metrics.json", {
    pod_volume_metrics = observe_dataset.pod_volume_metrics.id
    group_by           = jsonencode(lookup(each.value, "group_by", []))
    link = jsonencode(contains(keys(each.value), "target_dataset") ? {
      __typename       = "ForeignKey"
      srcFields        = each.value.src_fields,
      dstFields        = each.value.dst_fields,
      label            = each.value.label,
      targetDataset    = regexall(":([^/:]*)(/|$)", each.value.target_dataset)[0][0] # extract id from oid
      targetStageLabel = null,
      type             = "foreign",
    } : null)
  })
}
