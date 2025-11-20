data:extend({
  {
    type = "string-setting",
    name = "ufo-logLevel",
    order = "zz",
    setting_type = "runtime-global",
    default_value = "CONFIG",
    allowed_values = {
      "FATAL",
      "ERROR",
      "WARN",
      "INFO",
      "CONFIG",
      "FINE",
      "FINER",
      "FINEST",
    }
  },
})
