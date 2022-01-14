variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "name_format" {
  type        = string
  description = "Format string to use for dataset names. Override to introduce a prefix or suffix."
  default     = "%s"
}

variable "fluentbit" {
  description = "Fluentbit module"
  type = object({
    events = object({ oid = string })
  })
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
