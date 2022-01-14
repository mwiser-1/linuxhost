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

variable "raw_devices" {
  description = "Use raw devices for metrics as opposed to virtual devices"
  type        = bool
  default     = false
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
