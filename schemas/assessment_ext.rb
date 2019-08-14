{
  "records" => {
    "type" => "array",
    "ifmissing" => "error",
    "minItems" => 0,
    "items" => {
      "type" => "object",
      "subtype" => "ref",
      "properties" => {
        "ref" => {
          "type" => [{"type" => "JSONModel(:physical_representation) uri"}],
          "ifmissing" => "error"
        },
        "_resolved" => {
          "type" => "object",
          "readonly" => "true"
        }
      }
    }
  },
  "series" => {
    "type" => "array",
    "ifmissing" => "error",
    "readonly" => "true",
    "minItems" => 0,
    "items" => {
      "type" => "object",
      "subtype" => "ref",
      "properties" => {
        "ref" => {
          "type" => [{"type" => "JSONModel(:resource) uri"}],
          "ifmissing" => "error"
        },
        "_resolved" => {
          "type" => "object",
        }
      }
    }
  },
  "external_ids" => {"type" => "array", "items" => {"type" => "JSONModel(:external_id) object"}},
  "treatment_priority" => {"type" => "string", "dynamic_enum" => "runcorn_treatment_priority"},
  "conservation_request_id" => {"type" => "non_negative_integer"},
}
