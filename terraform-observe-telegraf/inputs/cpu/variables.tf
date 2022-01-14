variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "name_format" {
  type        = string
  description = "Format string to use for dataset names. Override to introduce a prefix or suffix."
  default     = "%s"
}

variable "telegraf" {
  description = "Telegraf module"
  type = object({
    events = object({ oid = string })
  })
}

variable "host_os_flags" {
  description = "List of host operating systems to grab metrics from"
  type        = list(string)
  default     = ["windows"]

  validation {
    condition     = length(setsubtract(distinct(flatten(["linux", "windows", "macos", var.host_os_flags])), ["linux", "windows", "macos"])) == 0
    error_message = "Allowed values for host_os_flags are \"linux\", \"windows\", or \"macos\"."
  }
}

variable "extract_tags" {
  description = "Additional tags to extract as columns."
  type        = list(string)
  default     = []
}

variable "link_targets" {
  description = "Datasets to link to."
  type = map(object({
    target = string
    fields = list(string)
  }))
  default = {}
}
