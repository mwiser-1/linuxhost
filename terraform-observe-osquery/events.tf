locals {
  create_events_dataset = var.events_dataset == null
}

resource "observe_dataset" "events" {
  count = local.create_events_dataset ? 1 : 0

  workspace = var.workspace.oid
  name      = format(var.name_format, "Events")
  icon_url  = "chromatography"

  description = <<-EOF
    This dataset contains raw osquery events, from which metric datasets can
    be derived.
  EOF

  inputs = {
    "observation" = data.observe_dataset.observation.oid
  }

  stage {
    input    = "observation"
    pipeline = <<-EOF
      filter OBSERVATION_KIND = "http" and string(EXTRA.path) = "/fluentbit/tail"
      make_col log:parse_json(string(FIELDS.log))
      make_col timestamp:from_seconds(int64(log.unixTime)), name:string(log.name), tags:make_object()
      make_col tags:make_fields(tags, host:string(FIELDS.host))
      make_col tags:make_fields(tags, datacenter:string(FIELDS.datacenter))
      make_col tags:make_fields(tags, appgroup:string(FIELDS.appgroup))
      make_col tags:make_fields(tags, ec2_instance_id:string(FIELDS.ec2_instance_id))
      make_col tags:make_fields(tags, ec2_instance_type:string(FIELDS.ec2_instance_type))
      make_col tags:make_fields(tags, ec2_az:string(FIELDS.az))

      set_valid_from options(max_time_diff:4h), timestamp
      pick_col
        timestamp,
        name,
        tags,
        log
        EOF
  }
}
