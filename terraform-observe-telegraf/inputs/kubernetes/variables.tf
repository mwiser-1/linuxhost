variable "workspace" {
  type        = object({ oid = string })
  description = "Workspace to apply module to."
}

variable "name_format" {
  type        = string
  description = "Format string to use for dataset names. Override to introduce a prefix or suffix."
  default     = "%s"
}

variable "kubernetes" {
  description = "Kubernetes module"
  type = object({
    cluster           = object({ oid = string })
    kubelet_metrics   = object({ oid = string })
    logical_container = object({ oid = string })
    namespace         = object({ oid = string })
    node              = object({ oid = string })
    pod               = object({ oid = string })
    volume            = object({ oid = string })
    deployment        = object({ oid = string })
    daemonset         = object({ oid = string })
    replicaset        = object({ oid = string })
    statefulset       = object({ oid = string })
    cronjob           = object({ oid = string })
    job               = object({ oid = string })
  })
}

variable "telegraf" {
  description = "Telegraf module"
  type = object({
    events = object({ oid = string })
  })
}

variable "allowed_metrics" {
  description = "List of metric names to be defined. If null, all metrics are configured"
  type        = set(string)
  default     = null
}

variable "ignored_metrics" {
  description = "List of metric names which should not be defined"
  type        = set(string)
  default     = null
}

variable "extra_container_metrics" {
  description = "Additional container metric definitions"
  type        = map(any)
  default     = {}
}

variable "extra_pod_network_metrics" {
  description = "Additional pod network metric definitions"
  type        = map(any)
  default     = {}
}

variable "extra_pod_volume_metrics" {
  description = "Additional pod volume metric definitions"
  type        = map(any)
  default     = {}
}

variable "extra_node_metrics" {
  description = "Additional node metric definitions"
  type        = map(any)
  default     = {}
}

variable "lookup_controllers" {
  description = "Link all pod metrics to respective Kubernetes controllers"
  type        = bool
  default     = false
}
