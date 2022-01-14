variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "observation_dataset" {
  type        = string
  description = "Name of dataset to derive fluentbit resources from."
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
  description = "Path on which HTTP fluentbit observations arrive."
  default     = "/fluentbit"
}

variable "merge_tags" {
  type        = list(string)
  description = "Tags to extract from HTTP observation and merge into Fluentbit tags."
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
  description = "Create (host) resource to link metrics to."
  default     = ["host", "log_file", "config_file"]

  validation {
    condition     = length(setsubtract(distinct(flatten(["host", "log_file", "config_file",  var.create_resources])), ["host", "log_file", "config_file"])) == 0
    error_message = "Allowed values for create_resources are \"host\", \"log_file\", and \"config_file\"."
  }
}

variable "max_expiry" {
  type        = string
  description = "Maximum expiry time for resources."
  default     = "30s"
}

variable "link_targets" {
  description = "Datasets to link to."
  type = map(object({
    target = string
    fields = list(string)
  }))
  default = {}
}
variable "file_formats" {
  type = map(
    object({
      time_format = string
      utc_offset  = number
    })
  )
  description = "Map of file formats to parse."
  default     = {"kern": {"time_format" = "noop", "utc_offset" = 0}}
}
