locals {
  create_events_dataset = var.events_dataset == null
}

resource "observe_dataset" "events" {
  count = local.create_events_dataset ? 1 : 0

  workspace = var.workspace.oid
  name      = format(var.name_format, "Events")
  icon_url  = "chromatography"

  description = <<-EOF
    This dataset contains raw telegraf events, from which metric datasets can
    be derived.
  EOF

  inputs = {
    "observation" = data.observe_dataset.observation.oid
  }

  stage {
    input    = "observation"
    pipeline = <<-EOF
      filter OBSERVATION_KIND = "http" and string(EXTRA.path) = "${var.path}"
      make_col timestamp:seconds(int64(FIELDS.timestamp)), name:string(FIELDS.name), tags:object(FIELDS.tags)
      set_valid_from options(max_time_diff:${var.max_time_diff}), timestamp
      ${join("\n\n", [for key in var.merge_tags : indent(2, format("make_col tags:make_fields(tags, %s:string(EXTRA.%s))", key, key))])}
      flatten_single FIELDS.fields
      pick_col
        timestamp,
        name,
        field:_c_FIELDS_fields_path,
        value:float64(_c_FIELDS_fields_value),
        tags
    EOF
  }
}
