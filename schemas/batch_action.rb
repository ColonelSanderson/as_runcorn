{
  :schema => {
    "$schema" => "http://www.archivesspace.org/archivesspace.json",
    "version" => 1,
    "type" => "object",
    "uri" => "/repositories/:repo_id/batch_actions",
    "properties" => {
      "uri" => {"type" => "string"},

      "note" => {"type" => "string"},

      "last_report" => {"type" => "string", "readonly" => "true"},

      "action_status" => {
        "type" => "string",
        "dynamic_enum" => "runcorn_batch_action_status",
        "default" => "draft",
      },

      "action_type" => {"type" => "string", "ifmissing" => "error"},
      "action_params" => {"type" => "string", "maxLength" => 8192},

      "action_user" => {"type" => "string", "ifmissing" => "error"},
      "action_time" => {"type" => "date-time"},

      "approved_user" => {"type" => "string"},
      "approved_time" => {"type" => "date-time"},

      "batch" => {
        "type" => "object",
        "subtype" => "ref",
        "properties" => {
          "ref" => {
            "type" => [{"type" => "JSONModel(:batch) uri"}],
          },
          "_resolved" => {
            "type" => "object",
            "readonly" => "true"
          }
        }
      },

      "display_string" => {
        "type" => "string",
        "readonly" => "true",
      },
    },
  },
}
