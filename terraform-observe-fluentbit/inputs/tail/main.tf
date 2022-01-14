locals {
  time_parsing = {
    "MMM DD HH:MM:SS" = {
      time_regex  = "(?P<month_str>...) (?P<day_str>..) (?P<hours_to_seconds>.{8})"
      parsed_time = <<-EOF
parseisotime(
  format_time(timestamp, "YYYY") + "-" +
  case(month_str = "Jan", "01",
       month_str = "Feb", "02",
       month_str = "Mar", "03",
       month_str = "Apr", "04",
       month_str = "May", "05",
       month_str = "Jun", "06",
       month_str = "Jul", "07",
       month_str = "Aug", "08",
       month_str = "Sep", "09",
       month_str = "Oct", "10",
       month_str = "Nov", "11",
       month_str = "Dec", "12") + "-" +
  day_str + "T" +
  hours_to_seconds + "Z") +
EOF
    }
    "noop" = {
      time_regex  = ""
      parsed_time = <<-EOF
timestamp +
EOF
    }
  }
}
