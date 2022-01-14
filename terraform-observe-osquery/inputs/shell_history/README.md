# OSQuery Shell History Input

This module registers metrics collected by the Shell History [input plugin](https://github.com/osquery/osquery/blob/master/specs/posix/shell_history.table)

## Usage

```hcl
provider "observe" {}

data "observe_workspace" "default" {
  name = "OSQuery"
}

module "osquery" {
  source           = "git@github.com:observeinc/terraform-observe-osquery.git"
  workspace        = data.observe_workspace.default
  create_resources = ["host", "users"]
  path             = "/osquery"
}

module "osquery_shell_history" {
  source       = "git@github.com:observeinc/terraform-observe-osquery.git//inputs/shell_history"
  workspace    = data.observe_workspace.default
  osquery      = module.osquery 
  extract_tags = ["host", "datacenter"]
  link_targets = {
    "host": {
      "target": module.osquery.host.oid,
      "fields": ["host", "datacenter"],
    },
    "users": {
      "target": module.osquery.users.oid,
      "fields": ["host", "datacenter", "uid"],
    }
  }
  name_format  = "OSQuery/%s"
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

| observe_dataset.shell_history | resource |

| observe_link.shell_history | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extract_tags"></a> [extract\_tags](#input\_extract\_tags) | Additional tags to extract as columns. | `list(string)` | `[]` | no |
| <a name="input_link_targets"></a> [link\_targets](#input\_link\_targets) | Datasets to link to. | <pre>map(object({<br>    target = string<br>    fields = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_max_time_diff"></a> [max\_time\_diff](#input\_max\_time\_diff) | Maximum time difference for processing time window. | `string` | `"4h"` | no |
| <a name="input_name_format"></a> [name\_format](#input\_name\_format) | Format string to use for dataset names. Override to introduce a prefix or suffix. | `string` | `"%s"` | no |
| <a name="input_osquery"></a> [osquery](#input\_osquery) | OSQuery module | <pre>object({<br>    events = object({ oid = string })<br>  })</pre> | n/a | yes |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Workspace to apply module to. | `object({ oid = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_shell_history"></a> [shell\_history](#output\_shell\_history) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.
