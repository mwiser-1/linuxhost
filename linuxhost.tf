terraform {
  required_providers {
    observe = {
      source  = "terraform.observeinc.com/observeinc/observe"
      version = "~> 0.4.0"
    }
  }
}

locals {
  extract_tags = ["host", "datacenter"]
  telegraf_name_format  = "Telegraf/%s"
  fluentbit_name_format = "Fluentbit/%s"
  osquery_name_format   = "OSQuery/%s"

  enable_telegraf                   = lookup(var.agents, "telegraf", false)
  enable_telegraf_processlist       = lookup(var.agents, "telegraf_processlist", false)
  link_targets = {
    "Host" : {
      "target" : module.osquery.host.oid,
      "fields" : ["host", "datacenter"],
    }
  }
}

module "osquery" {
  source           = "./terraform-observe-osquery"
  workspace        = var.workspace
  observation_dataset = var.observation_dataset
  link_targets = local.link_targets
  merge_tags       = ["host", "datacenter"]
  path        = "/fluentbit/tail"
  name_format = local.osquery_name_format
}

module "fluentbit" {
  source = "./terraform-observe-fluentbit"
  workspace        = var.workspace
  observation_dataset = var.observation_dataset
  link_targets = local.link_targets
  path        = "/fluentbit"
  name_format = local.fluentbit_name_format
}

module "telegraf" {
  count            = local.enable_telegraf ? 1 : 0
  source           = "./terraform-observe-telegraf"
  workspace        = var.workspace
  observation_dataset = var.observation_dataset
  link_targets     = local.link_targets
  path        = "/telegraf"
  name_format = local.telegraf_name_format
}
module "telegraf_cpu" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/cpu"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}
module "telegraf_diskio" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/diskio"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}
module "telegraf_mem" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/mem"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}
module "telegraf_disk" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/disk"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = merge(local.link_targets,
    {
      "volume" : {
        "target" : module.osquery.volume.oid,
        "fields" : ["host", "datacenter", "volume"],
      }
    }
  )
  name_format = local.telegraf_name_format
}

module "telegraf_kernel" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/kernel"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}

module "telegraf_processes" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/processes"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}
module "telegraf_swap" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/swap"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}

module "telegraf_system" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/system"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}

module "telegraf_ntpq" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/ntpq"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}
module "telegraf_linux_sysctl_fs" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/linux_sysctl_fs"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}

module "telegraf_net" {
  count        = local.enable_telegraf ? 1 : 0
  source       = "./terraform-observe-telegraf//inputs/net"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  link_targets = merge(local.link_targets,
    {
      "interface" : {
        "target" : module.osquery.interface.oid,
        "fields" : ["host", "datacenter", "interface"],
      }
    }
  )
  name_format = local.telegraf_name_format
}
module "telegraf_processlist" {
  count        = local.enable_telegraf_processlist ? 1 : 0
  source       = "./processlist"
  workspace    = var.workspace
  telegraf     = module.telegraf[0]
  extract_tags = local.extract_tags
  observation_dataset = var.observation_dataset
  link_targets = local.link_targets
  name_format  = local.telegraf_name_format
}
resource "observe_board" "host_board_metrics" {
  count   = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.host.oid
  name    = "Linux Host Summary - BetaBoard with Metrics"
  type    = "set"
  json = templatefile("${path.module}/boards/LinuxHostSummaryMetrics.json", {
    dataset_telegraf_systemMetrics    = regexall(":([^/:]*)(/|$)", module.telegraf_system[0].system_metrics.oid)[0][0]       # extract id from oid  
    dataset_server_host               = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0]                            # extract id from oid
    dataset_telegraf_memMetrics       = regexall(":([^/:]*)(/|$)", module.telegraf_mem[0].mem_metrics.oid)[0][0]             # extract id from oid
    dataset_telegraf_processesMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_processes[0].processes_metrics.oid)[0][0] # extract id from oid
    dataset_telegraf_cPUMetrics       = regexall(":([^/:]*)(/|$)", module.telegraf_cpu[0].cpu_metrics.oid)[0][0]
    dataset_telegraf_netMetrics       = regexall(":([^/:]*)(/|$)", module.telegraf_net[0].net_metrics.oid)[0][0]   # extract id from oid
    dataset_telegraf_diskMetrics      = regexall(":([^/:]*)(/|$)", module.telegraf_disk[0].disk_metrics.oid)[0][0] # extract id from oid

  })
}
resource "observe_board" "single_host_board_metrics" {
  count   = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.host.oid
  name    = "Linux Single Host Summary - BetaBoard with Metrics"
  type    = "singleton"
  json = templatefile("${path.module}/boards/LinuxSingleHostSummaryMetrics.json", {
    dataset_telegraf_systemMetrics    = regexall(":([^/:]*)(/|$)", module.telegraf_system[0].system_metrics.oid)[0][0]       # extract id from oid  
    dataset_server_host               = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0]                            # extract id from oid
    dataset_telegraf_memMetrics       = regexall(":([^/:]*)(/|$)", module.telegraf_mem[0].mem_metrics.oid)[0][0]             # extract id from oid
    dataset_telegraf_processesMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_processes[0].processes_metrics.oid)[0][0] # extract id from oid
    dataset_telegraf_cPUMetrics       = regexall(":([^/:]*)(/|$)", module.telegraf_cpu[0].cpu_metrics.oid)[0][0]
    dataset_telegraf_netMetrics       = regexall(":([^/:]*)(/|$)", module.telegraf_net[0].net_metrics.oid)[0][0]   # extract id from oid
    dataset_telegraf_diskMetrics      = regexall(":([^/:]*)(/|$)", module.telegraf_disk[0].disk_metrics.oid)[0][0] # extract id from oid

  })
}
resource "observe_board" "host_interface" {
  count   = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.interface.oid
  name    = "Linux Interface Summary - BetaBoard with Metrics"
  type    = "set"
  json = templatefile("${path.module}/boards/InterfaceOverview.json", {
    dataset_server_host         = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0]                # extract id from oid
    dataset_telegraf_netMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_net[0].net_metrics.oid)[0][0] # extract id from oid
    dataset_server_interface    = regexall(":([^/:]*)(/|$)", module.osquery.interface.oid)[0][0]           # extract id from oid
  })
}

resource "observe_board" "host_volume" {
  count   = local.enable_telegraf ? 1 : 0
  dataset = module.osquery.volume.oid
  name    = "Linux Volume Summary - BetaBoard with Metrics"
  type    = "set"
  json = templatefile("${path.module}/boards/VolumeOverview.json", {
    dataset_server_host          = regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0]                  # extract id from oid
    dataset_telegraf_diskMetrics = regexall(":([^/:]*)(/|$)", module.telegraf_disk[0].disk_metrics.oid)[0][0] # extract id from oid
    dataset_server_volume        = regexall(":([^/:]*)(/|$)", module.osquery.volume.oid)[0][0]                # extract id from oid
  })
}

resource "observe_board" "processlist" {
  count   = local.enable_telegraf_processlist ? 1 : 0
  dataset = module.osquery.host.oid
  name    = "Linux ProcessList Summary - BetaBoard with Metrics"
  type    = "singleton"
  json = templatefile("${path.module}/boards/LinuxSingleHostProcessSummary.json", {
    "dataset_telegraf_processListMetrics" : regexall(":([^/:]*)(/|$)", module.telegraf_processlist[0].processlist_metrics.oid)[0][0]
    "dataset_server_host" : regexall(":([^/:]*)(/|$)", module.osquery.host.oid)[0][0]                        # extract id from oid
    "dataset_telegraf_memMetrics" : regexall(":([^/:]*)(/|$)", module.telegraf_mem[0].mem_metrics.oid)[0][0] # extract id from oid
    "dataset_telegraf_cPUMetrics" : regexall(":([^/:]*)(/|$)", module.telegraf_cpu[0].cpu_metrics.oid)[0][0]
  })
}
