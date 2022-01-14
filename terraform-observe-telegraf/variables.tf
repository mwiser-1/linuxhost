variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "observation_dataset" {
  type        = string
  description = "Name of dataset to derive telegraf resources from."
  default     = "Observation"
}

variable "name_format" {
  type        = string
  description = "Format string to use for dataset names. Override to introduce a prefix or suffix."
  default     = "%s"
}

variable "max_time_diff" {
  type        = string
  description = "Maximum time difference for processing time window."
  default     = "4h"
}

variable "path" {
  type        = string
  description = "Path on which HTTP telegraf observations arrive."
  default     = "/telegraf"
}

variable "merge_tags" {
  type        = list(string)
  description = "Tags to extract from HTTP observation and merge into Telegraf tags."
  default     = []
}

variable "events_dataset" {
  type        = object({ oid = string })
  description = "Override events dataset used."
  default     = null
}

variable "extract_tags" {
  description = "Additional tags to extract as columns."
  type        = list(string)
  default     = ["host", "datacenter"]
}

variable "create_resources" {
  type        = list(string)
  description = "Create one or more of (host, volume, interface) resources to link metrics to."
  default     = ["host", "volume", "interface"]

  validation {
    condition     = length(setsubtract(distinct(flatten(["host", "volume", "interface", var.create_resources])), ["host", "volume", "interface"])) == 0
    error_message = "Allowed values for create_resources are \"host\", \"volume\", or \"interface\"."
  }
}

variable "link_targets" {
  description = "Datasets to link to."
  type = map(object({
    target = string
    fields = list(string)
  }))
  default = {}
}
