resource "observe_dataset" "events" {
  workspace   = var.workspace.oid
  name        = format(var.name_format, "Logs")
  icon_url    = "diff-files"
  description = "Tail Log Events"

  inputs = {
    "events" = var.fluentbit.events.oid
  }

  // make one stage per parse_type, then union them all together at the end
  dynamic "stage" {
    for_each = var.file_formats

    content {
      input    = "events"
      alias    = stage.key
      pipeline = <<-EOF
        filter string(inputType) = "/fluentbit/tail"
        filter string(event["parse_type"]) = "${stage.key}"

        ${local.time_parsing[stage.value.time_format].time_regex != "" ? "extract_regex string(event.time), /${local.time_parsing[stage.value.time_format].time_regex}/" : ""}
        make_col parsed_time:${local.time_parsing[stage.value.time_format].parsed_time}  duration_hr(${stage.value.utc_offset})
        set_valid_from parsed_time

        pick_col
          timestamp:parsed_time,
          message:string(event["message"]),
          path:string(event["path"]),
          name,
          parse_type:event["parse_type"],
          ${indent(2, join("\n", [for tag in var.extract_tags : format("%s:string(tags.%s),", tag, tag)]))}
          event

	  EOF
    }
  }
  stage {
    pipeline = <<-EOF
    union ${join(", ", [for stage_name, val in var.file_formats : "@${stage_name}"])}
    colshow event:false, parse_type:false
    EOF
  }
}

resource "observe_link" "events" {
  for_each = var.link_targets

  workspace = var.workspace.oid
  source    = observe_dataset.events.oid
  target    = each.value.target
  fields    = each.value.fields
  label     = each.key
}
