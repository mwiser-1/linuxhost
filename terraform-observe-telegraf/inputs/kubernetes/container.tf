locals {
  container_metrics_facet = {
    "Cluster"     = "Namespace"
    "Namespace"   = "Pod"
    "Node"        = "Pod"
    "Deployment"  = "ReplicaSet"
    "CronJob"     = "Job"
    "Job"         = "Pod"
    "DaemonSet"   = "Pod"
    "StatefulSet" = "Pod"
    "ReplicaSet"  = "Pod"
    "Pod"         = "Container"
  }

  base_container_metrics = {
    "cpu_usage_cores" = {
      label       = "CPU Usage Cores"
      type        = "gauge"
      description = "Total CPU usage (sum of all cores) averaged over the sample window"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "cpu_usage_core_seconds" = {
      label       = "CPU Usage Core Seconds"
      type        = "cumulativeCounter"
      unit        = "seconds"
      description = "Cumulative CPU usage (sum of all cores) since object creation",
      rollup      = "rate"
      aggregate   = "sum"
    }
    "memory_page_faults" = {
      label       = "Minor Page Faults"
      type        = "cumulativeCounter"
      description = "Cumulative number of minor page faults"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "memory_major_page_faults" = {
      label       = "Major Page Faults"
      type        = "cumulativeCounter"
      description = "Cumulative number of major page faults"
      rollup      = "rate"
      aggregate   = "sum"
    }
    "memory_usage_bytes" = {
      label       = "Memory Usage"
      type        = "gauge"
      unit        = "bytes"
      description = "Total memory in use. This includes all memory regardless of when it was accessed"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "memory_rss_bytes" = {
      label       = "RSS Memory"
      type        = "gauge"
      unit        = "bytes"
      description = "The amount of anonymous and swap cache memory (includes transparent hugepages)"
      rollup      = "avg"
      aggregate   = "sum"
    }
    "memory_working_set_bytes" = {
      label       = "Working Set Memory"
      type        = "gauge"
      unit        = "bytes"
      description = "The amount of working set memory. This includes recently accessed memory, dirty memory, and kernel memory. WorkingSetBytes is at most equal to UsageBytes"
      rollup      = "avg"
      aggregate   = "sum"
    }


    /*
      // TBD
      // logsfs_available_bytes
      // logsfs_capacity_bytes
      // logsfs_used_bytes
      //
      // rootfs_available_bytes
      // rootfs_capacity_bytes
      // rootfs_used_bytes
    */
  }

  container_metrics = {
    for k, v in merge(local.base_container_metrics, var.extra_container_metrics) : k => v
    if((var.allowed_metrics == null ? true : contains(var.allowed_metrics, k)) && (var.ignored_metrics == null ? true : !contains(var.ignored_metrics, k)))
  }
}

resource "observe_dataset" "container_metrics" {
  workspace = var.workspace.oid
  name      = format(var.name_format, "Container Metrics")

  inputs = merge({
    "events" = var.telegraf.events.oid
    }, var.lookup_controllers ? {
    "pod" = var.kubernetes.pod.oid
    } : {}
  )

  stage {
    alias    = "system_container_metrics"
    input    = "events"
    pipeline = <<-EOF
      // this stage contains CPU metrics for cgroups not associated with
      // kubernetes pods (runtime + kubelet). Unioning this data with CPU
      // metrics for kubernetes containers will result in the correct total CPU
      // usage per node.
      filter name = "kubernetes_system_container" and startswith(field, "cpu_usage") and string(tags["container_name"]) != "pods"
    EOF
  }

  stage {
    input    = "events"
    pipeline = <<-EOF
      filter name = "kubernetes_pod_container"
      union @system_container_metrics

      make_col
        field:if(field = "cpu_usage_core_nanoseconds", "cpu_usage_core_seconds", field),
        value:if(field = "cpu_usage_core_nanoseconds", value / pow(10, 9), value)
      make_col
        field:if(field = "cpu_usage_nanocores", "cpu_usage_cores", field),
        value:if(field = "cpu_usage_nanocores", value / pow(10, 9), value)

      pick_col
        timestamp,
        clusterUid:string(tags.clusterUid),
        namespace:string(tags.namespace),
        podName:string(tags.pod_name),
        containerName:string(tags.container_name),
        nodeName:string(tags.node_name),
        field,
        value

      interface "metric", metric:field, value:value
      ${join("\n\n", [for metric, options in local.container_metrics : indent(2, format("set_metric options(\n%s\n), %q", join(",\n", [for k, v in options : format("%s: %q", k, v)]), metric))])}
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

resource "observe_link" "container_metrics" {
  workspace = var.workspace.oid
  source    = observe_dataset.container_metrics.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key

  for_each = merge(
    {
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
      "Container" = {
        target = var.kubernetes.logical_container.oid
        fields = ["clusterUid", "namespace", "podName", "containerName:name"]
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

resource "observe_board" "container_metrics" {
  for_each = merge(
    {
      "Base" = {
        board_dataset = observe_dataset.container_metrics.oid
        type          = "set"
      }
    },
    # Inherit set board defined on metric dataset if there is a link towards a resource
    { for k, v in observe_link.container_metrics :
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
    { for k, v in observe_link.container_metrics :
      format("Singleton_%s", k) => {
        type           = "singleton"
        board_dataset  = v.target
        target_dataset = observe_link.container_metrics[local.container_metrics_facet[k]].target
        label          = local.container_metrics_facet[k]
        src_fields     = [for field in v.fields : try(element(split(":", field), 0), field)]
        dst_fields     = [for field in v.fields : try(element(split(":", field), 1), field)]
        group_by       = [for field in observe_link.container_metrics[local.container_metrics_facet[k]].fields : try(element(split(":", field), 0), field)]
      } if contains(keys(local.container_metrics_facet), k)
    },
    # Inherit singleton board defined on metric dataset in absence of available facet
    { for k, v in observe_link.container_metrics :
      format("Singleton_%s", k) => {
        type          = "singleton"
        board_dataset = v.target
      } if !contains(keys(local.container_metrics_facet), k)
    },
  )

  dataset = each.value.board_dataset
  name    = "Container Metrics"
  type    = each.value.type
  json = templatefile("${path.module}/boards/container_metrics.json", {
    container_metrics = observe_dataset.container_metrics.id
    group_by          = jsonencode(lookup(each.value, "group_by", []))
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
