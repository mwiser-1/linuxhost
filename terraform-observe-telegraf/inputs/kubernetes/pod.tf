locals {
  pod_network_metrics_facet = {
    "Cluster"     = "Namespace"
    "Namespace"   = "Pod"
    "Node"        = "Pod"
    "Deployment"  = "ReplicaSet"
    "CronJob"     = "Job"
    "Job"         = "Pod"
    "DaemonSet"   = "Pod"
    "StatefulSet" = "Pod"
    "ReplicaSet"  = "Pod"
  }

  base_pod_network_metrics = {
    "tx_bytes" = {
      label       = "Bytes Sent",
      type        = "cumulativeCounter",
      unit        = "bytes",
      description = "Total bytes sent",
      rollup      = "rate",
      aggregate   = "sum"
    }
    "rx_bytes" = {
      label       = "Bytes Received",
      type        = "cumulativeCounter",
      unit        = "bytes",
      description = "Total bytes received",
      rollup      = "rate",
      aggregate   = "sum"
    }
    "tx_errors" = {
      label       = "Tx Errors",
      type        = "cumulativeCounter",
      description = "Total number of transmission errors",
      rollup      = "rate",
      aggregate   = "sum"
    },
    "rx_errors" = {
      label       = "Rx Errors",
      type        = "cumulativeCounter",
      description = "Total receive error count",
      rollup      = "rate",
      aggregate   = "sum"
    }
  }

  pod_network_metrics = {
    for k, v in merge(local.base_pod_network_metrics, var.extra_pod_network_metrics) : k => v
    if((var.allowed_metrics == null ? true : contains(var.allowed_metrics, k)) && (var.ignored_metrics == null ? true : !contains(var.ignored_metrics, k)))
  }
}

resource "observe_dataset" "pod_network_metrics" {
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Pod Network Metrics")
  description = <<-EOF
    Pod network metrics collected from the Kubelet API.
  EOF

  inputs = merge({
    "events" = var.telegraf.events.oid
    }, var.lookup_controllers ? {
    "pod" = var.kubernetes.pod.oid
    } : {}
  )

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "kubernetes_pod_network"
      pick_col
        timestamp,
        clusterUid:string(tags.clusterUid),
        namespace:string(tags.namespace),
        podName:string(tags.pod_name),
        nodeName:string(tags.node_name),
        field,
        value,
        tags

      interface "metric", metric:field, value:value
      ${join("\n\n", [for metric, options in local.pod_network_metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
    EOF
  }

  dynamic "stage" {
    for_each = var.lookup_controllers ? [1] : []
    content {
      pipeline = <<-EOF
      lookup clusterUid=@pod.clusterUid, namespace=@pod.namespace, podName=@pod.name,
        deploymentName:@pod.deploymentName,
        cronjobName:@pod.cronjobName,
        jobName:@pod.jobName,
        statefulsetName:@pod.statefulsetName,
        daemonsetName:@pod.daemonsetName,
        replicasetName:@pod.replicasetName
    EOF
    }
  }
}

resource "observe_link" "pod_network_metrics" {
  workspace = var.workspace.oid
  source    = observe_dataset.pod_network_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key

  for_each = merge({
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
    },
    var.lookup_controllers ? {
      "CronJob" = {
        target = var.kubernetes.cronjob.oid
        fields = ["clusterUid", "namespace", "cronjobName:name"]
      }
      "Job" = {
        target = var.kubernetes.job.oid
        fields = ["clusterUid", "namespace", "jobName:name"]
      }
      "DaemonSet" = {
        target = var.kubernetes.daemonset.oid
        fields = ["clusterUid", "namespace", "daemonsetName:name"]
      }
      "Deployment" = {
        target = var.kubernetes.deployment.oid
        fields = ["clusterUid", "namespace", "deploymentName:name"]
      }
      "ReplicaSet" = {
        target = var.kubernetes.replicaset.oid
        fields = ["clusterUid", "namespace", "replicasetName:name"]
      }
      "StatefulSet" = {
        target = var.kubernetes.statefulset.oid
        fields = ["clusterUid", "namespace", "statefulsetName:name"]
      }
  } : {})
}

resource "observe_board" "pod_network_metrics" {
  for_each = merge(
    {
      "Base" = {
        board_dataset = observe_dataset.pod_network_metrics.oid
        type          = "set"
      }
    },
    # Inherit set board defined on metric dataset if there is a link towards a resource
    { for k, v in observe_link.pod_network_metrics :
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
    { for k, v in observe_link.pod_network_metrics :
      format("Singleton_%s", k) => {
        type           = "singleton"
        board_dataset  = v.target
        target_dataset = observe_link.pod_network_metrics[local.pod_network_metrics_facet[k]].target
        label          = local.pod_network_metrics_facet[k]
        src_fields     = [for field in v.fields : try(element(split(":", field), 0), field)]
        dst_fields     = [for field in v.fields : try(element(split(":", field), 1), field)]
        group_by       = [for field in observe_link.pod_network_metrics[local.pod_network_metrics_facet[k]].fields : try(element(split(":", field), 0), field)]
      } if contains(keys(local.pod_network_metrics_facet), k)
    },
    # Inherit singleton board defined on metric dataset in absence of available facet
    { for k, v in observe_link.pod_network_metrics :
      format("Singleton_%s", k) => {
        type          = "singleton"
        board_dataset = v.target
      } if !contains(keys(local.pod_network_metrics_facet), k)
    },
  )

  dataset = each.value.board_dataset
  name    = "Pod Network Metrics"
  type    = each.value.type
  json = templatefile("${path.module}/boards/pod_network_metrics.json", {
    pod_network_metrics = observe_dataset.pod_network_metrics.id
    group_by            = jsonencode(lookup(each.value, "group_by", []))
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
