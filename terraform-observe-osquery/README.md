# Observe OSQuery module

This is very much work in progress

## Usage

```hcl
data "observe_workspace" "default" {
  name = "Default"
}

module "osquery" {
  source            = "git@github.com:observeinc/terraform-observe-osquery.git"
  workspace         = data.observe_workspace.default
  path              = "/osquery"
  name_format       = "OSQuery/%s"
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

| observe_dataset.logged_in_users | resource |

| observe_dataset.users | resource |

| observe_dataset.volume | resource |

| observe_link.interface | resource |

| observe_link.logged_in_users | resource |

| observe_link.users | resource |

| observe_link.volume | resource |

| observe_dataset.observation | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_resources"></a> [create\_resources](#input\_create\_resources) | Create one or more of (host, volume, interface, users, shell\_history) resources to link metrics to. | `list(string)` | <pre>[<br>  "host",<br>  "volume",<br>  "interface",<br>  "users",<br>  "shell_history"<br>]</pre> | no |
| <a name="input_events_dataset"></a> [events\_dataset](#input\_events\_dataset) | Override events dataset used. | `object({ oid = string })` | `null` | no |
| <a name="input_extract_tags"></a> [extract\_tags](#input\_extract\_tags) | Additional tags to extract as columns. | `list(string)` | <pre>[<br>  "host",<br>  "datacenter"<br>]</pre> | no |
| <a name="input_link_targets"></a> [link\_targets](#input\_link\_targets) | Datasets to link to. | <pre>map(object({<br>    target = string<br>    fields = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_max_time_diff"></a> [max\_time\_diff](#input\_max\_time\_diff) | Maximum time difference for processing time window. | `string` | `"4h"` | no |
| <a name="input_merge_tags"></a> [merge\_tags](#input\_merge\_tags) | Tags to extract from HTTP observation and merge into OSQuery tags. | `list(string)` | `[]` | no |
| <a name="input_name_format"></a> [name\_format](#input\_name\_format) | Format string to use for dataset names. Override to introduce a prefix or suffix. | `string` | `"%s"` | no |
| <a name="input_observation_dataset"></a> [observation\_dataset](#input\_observation\_dataset) | Name of dataset to derive osquery resources from. | `string` | `"Observation"` | no |
| <a name="input_path"></a> [path](#input\_path) | Path on which HTTP osquery observations arrive. | `string` | `"/fluentbit/tail"` | no |
| <a name="input_resource_name_format"></a> [resource\_name\_format](#input\_resource\_name\_format) | Format string to use for resource names. Override to introduce a prefix or suffix. | `string` | `"Server/%s"` | no |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Workspace to apply module to. | `object({ oid = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_events"></a> [events](#output\_events) | n/a |
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_interface"></a> [interface](#output\_interface) | n/a |
| <a name="output_logged_in_users"></a> [logged\_in\_users](#output\_logged\_in\_users) | n/a |
| <a name="output_users"></a> [users](#output\_users) | n/a |
| <a name="output_volume"></a> [volume](#output\_volume) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.
