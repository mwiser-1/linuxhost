variable "agents" {
  type        = map(bool)
  description = "This is used to find associated boards - including or excluding metrics (Telegraf)"
  default     = {
    telegraf = true
    telegraf_processlist = false
  }
}

variable "name_format" {
  type        = string
  description = "Format string to use for dataset names. Override to introduce a prefix or suffix."
  default     = "%s"
}


variable "enable_telegraf" {
  type        = bool
  default     = false
}
variable "enable_telegraf_processlist" {
  type        = bool
  default     = false
}

variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "observation_dataset" {
  type        = string
  description = "Name of dataset to derive resources from."
  default     = "Observation"
}

variable "max_expiry" {
  type        = number
  description = "Maximum expiry time for resources in minutes."
  default     = 90
}

variable "freshness_overrides" {
  type        = map(string)
  description = "Freshness overrides by dataset. If absent, fall back to freshness_default"
  default     = {}
}

variable "freshness_default" {
  type        = string
  description = "Default dataset freshness. Can be overridden with freshness input"
  default     = "1m"
}

variable "ec2" {
  description = "AWS EC2 module"
  default     = null
  type = object({
    instance = object({ oid = string })
  })
}
