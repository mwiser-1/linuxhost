# Observe Telegraf module

This is very much work in progress

## Usage

```hcl
data "observe_workspace" "default" {
  name = "Default"
}

module "telegraf" {
  source            = "git@github.com:observeinc/terraform-observe-telegraf.git"
  workspace         = data.observe_workspace.default
  path              = "/telegraf"
  name_format       = "Telegraf/%s"
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
| <a name="provider_observe"></a> [observe](#provider\_observe) | 0.4.13 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|

| observe_dataset.events | resource |

| observe_dataset.host | resource |

| observe_dataset.interface | resource |

| observe_dataset.volume | resource |

| observe_link.interface | resource |

| observe_link.volume | resource |

| observe_dataset.observation | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_resources"></a> [create\_resources](#input\_create\_resources) | Create one or more of (host, volume, interface) resources to link metrics to. | `list(string)` | <pre>[<br>  "host",<br>  "volume",<br>  "interface"<br>]</pre> | no |
| <a name="input_events_dataset"></a> [events\_dataset](#input\_events\_dataset) | Override events dataset used. | `object({ oid = string })` | `null` | no |
| <a name="input_extract_tags"></a> [extract\_tags](#input\_extract\_tags) | Additional tags to extract as columns. | `list(string)` | <pre>[<br>  "host",<br>  "datacenter"<br>]</pre> | no |
| <a name="input_link_targets"></a> [link\_targets](#input\_link\_targets) | Datasets to link to. | <pre>map(object({<br>    target = string<br>    fields = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_max_time_diff"></a> [max\_time\_diff](#input\_max\_time\_diff) | Maximum time difference for processing time window. | `string` | `"4h"` | no |
| <a name="input_merge_tags"></a> [merge\_tags](#input\_merge\_tags) | Tags to extract from HTTP observation and merge into Telegraf tags. | `list(string)` | `[]` | no |
| <a name="input_name_format"></a> [name\_format](#input\_name\_format) | Format string to use for dataset names. Override to introduce a prefix or suffix. | `string` | `"%s"` | no |
| <a name="input_observation_dataset"></a> [observation\_dataset](#input\_observation\_dataset) | Name of dataset to derive telegraf resources from. | `string` | `"Observation"` | no |
| <a name="input_path"></a> [path](#input\_path) | Path on which HTTP telegraf observations arrive. | `string` | `"/telegraf"` | no |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Workspace to apply module to. | `object({ oid = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_events"></a> [events](#output\_events) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_interface"></a> [interface](#output\_interface) | n/a |
| <a name="output_volume"></a> [volume](#output\_volume) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.
