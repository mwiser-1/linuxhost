# Telegraf Kubernetes Input

This module registers metrics collected by the Kubernetes [input plugin](https://github.com/influxdata/telegraf/blob/master/plugins/inputs/kubernetes/README.md)

## Usage

```hcl
provider "observe" {}

data "observe_workspace" "default" {
  name = "Kubernetes"
}

module "kubernetes" {
  source    = "git@github.com:observeinc/terraform-observe-kubernetes.git"
  workspace = data.observe_workspace.default
}

module "telegraf" {
  source        = "git@github.com:observeinc/terraform-observe-telegraf.git"
  workspace     = data.observe_workspace.default
  path          = "/kubernetes/telegraf"
  extra_to_tags = ["clusterUid"]
}

module "kubernetes_metrics" {
  source     = "git@github.com:observeinc/terraform-observe-telegraf.git//inputs/kubernetes"
  workspace  = data.observe_workspace.default
  telegraf   = module.telegraf
  kubernetes = module.kubernetes
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_observe"></a> [observe](#requirement\_observe) | ~> 0.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_observe"></a> [observe](#provider\_observe) | 0.4.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

| observe_board.container_metrics | resource |

| observe_board.pod_network_metrics | resource |

| observe_board.pod_volume_metrics | resource |

| observe_dataset.container_metrics | resource |

| observe_dataset.node_metrics | resource |

| observe_dataset.pod_network_metrics | resource |

| observe_dataset.pod_volume_metrics | resource |

| observe_link.container_metrics | resource |

| observe_link.node_metrics | resource |

| observe_link.pod_network_metrics | resource |

| observe_link.pod_volume_metrics | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_metrics"></a> [allowed\_metrics](#input\_allowed\_metrics) | List of metric names to be defined. If null, all metrics are configured | `set(string)` | `null` | no |
| <a name="input_extra_container_metrics"></a> [extra\_container\_metrics](#input\_extra\_container\_metrics) | Additional container metric definitions | `map(any)` | `{}` | no |
| <a name="input_extra_node_metrics"></a> [extra\_node\_metrics](#input\_extra\_node\_metrics) | Additional node metric definitions | `map(any)` | `{}` | no |
| <a name="input_extra_pod_network_metrics"></a> [extra\_pod\_network\_metrics](#input\_extra\_pod\_network\_metrics) | Additional pod network metric definitions | `map(any)` | `{}` | no |
| <a name="input_extra_pod_volume_metrics"></a> [extra\_pod\_volume\_metrics](#input\_extra\_pod\_volume\_metrics) | Additional pod volume metric definitions | `map(any)` | `{}` | no |
| <a name="input_ignored_metrics"></a> [ignored\_metrics](#input\_ignored\_metrics) | List of metric names which should not be defined | `set(string)` | `null` | no |
| <a name="input_kubernetes"></a> [kubernetes](#input\_kubernetes) | Kubernetes module | <pre>object({<br>    cluster           = object({ oid = string })<br>    kubelet_metrics   = object({ oid = string })<br>    logical_container = object({ oid = string })<br>    namespace         = object({ oid = string })<br>    node              = object({ oid = string })<br>    pod               = object({ oid = string })<br>    volume            = object({ oid = string })<br>    deployment        = object({ oid = string })<br>    daemonset         = object({ oid = string })<br>    replicaset        = object({ oid = string })<br>    statefulset       = object({ oid = string })<br>    cronjob           = object({ oid = string })<br>    job               = object({ oid = string })<br>  })</pre> | n/a | yes |
| <a name="input_lookup_controllers"></a> [lookup\_controllers](#input\_lookup\_controllers) | Link all pod metrics to respective Kubernetes controllers | `bool` | `false` | no |
| <a name="input_name_format"></a> [name\_format](#input\_name\_format) | Format string to use for dataset names. Override to introduce a prefix or suffix. | `string` | `"%s"` | no |
| <a name="input_telegraf"></a> [telegraf](#input\_telegraf) | Telegraf module | <pre>object({<br>    events = object({ oid = string })<br>  })</pre> | n/a | yes |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Workspace to apply module to. | `object({ oid = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_metrics"></a> [container\_metrics](#output\_container\_metrics) | n/a |
| <a name="output_node_metrics"></a> [node\_metrics](#output\_node\_metrics) | n/a |
| <a name="output_pod_network_metrics"></a> [pod\_network\_metrics](#output\_pod\_network\_metrics) | n/a |
| <a name="output_pod_volume_metrics"></a> [pod\_volume\_metrics](#output\_pod\_volume\_metrics) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.
