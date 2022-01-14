# Fluentbit Tail Input

This module registers metrics collected by the Tail [input plugin](https://docs.fluentbit.io/manual/pipeline/inputs/tail)

## Usage

```hcl
provider "observe" {}

data "observe_workspace" "default" {
  name = "Fluentbit"
}

module "fluentbit" {
  source    = "git@github.com:observeinc/terraform-observe-fluentbit.git"
  workspace = data.observe_workspace.default
  path      = "/fluentbit"
}

module "fluentbit_tail" {
  source       = "git@github.com:observeinc/terraform-observe-fluentbit.git//inputs/tail"
  workspace    = data.observe_workspace.default
  fluentbit    = module.fluentbit
  extract_tags = ["host", "datacenter"]
  link_targets = {
    "host": {
      "target": module.fluentbit.host.oid,
      "fields": ["host", "datacenter"],
    }
  }
  file_formats = {
    "auth": {
      "time_format" = "MMM DD HH:MM:SS",
      "utc_offset" = 7
    },
    "kern": {
      "time_format" = "noop",
      "utc_offset" = 0
    }
  }
  name_format  = "Fluentbit/%s"
}
```

Unlike systemd, log files can have any number of time formats, possibly multiple per host. To this end the tail module supports established time formats defined in locals in main.tf as well as support for time offsets to convert these times into UTC. The keys in file_formats correspond to the parse_type key matched on each log line, and will likely need to be provided in a FILTER structure after the INPUT.

Details about keys:
time_format: This is a string that must be matched in main.tf's locals which define how to transform the identified time coidentified time column. Due to the way that fluentbit's multiline parser works this time column will need to be identified before it reaches Observe
utc_offset: Hours to add to the current time to make it UTC. Will need to be reset periodically to deal with daylight savings time changes

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

| observe_dataset.cpu_metrics | resource |

| observe_link.cpu_metrics | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_extract_tags"></a> [extract\_tags](#input\_extract\_tags) | Additional tags to extract as columns. | `list(string)` | `[]` | no |
| <a name="input_link_targets"></a> [link\_targets](#input\_link\_targets) | Datasets to link to. | <pre>map(object({<br>    target = string<br>    fields = list(string)<br>  }))</pre> | `{}` | no |
| <a name="input_name_format"></a> [name\_format](#input\_name\_format) | Format string to use for dataset names. Override to introduce a prefix or suffix. | `string` | `"%s"` | no |
| <a name="input_telegraf"></a> [telegraf](#input\_telegraf) | Telegraf module | <pre>object({<br>    events = object({ oid = string })<br>  })</pre> | n/a | yes |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Workspace to apply module to. | `object({ oid = string })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cpu_metrics"></a> [cpu\_metrics](#output\_cpu\_metrics) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## License

Apache 2 Licensed. See LICENSE for full details.

