locals {
  # Decode the YAML file and get the map of namespaces
  namespaces_raw = yamldecode(file("${path.module}/namespaces.yaml"))

  # Access namespaces directly as a map
  namespaces = local.namespaces_raw.namespaces
}

# OR logic: Output the list as is for "cats"
output "namespace_cats" {
  value = { for k, v in local.namespaces : k => coalesce(lookup(v, "cats", []), []) }
}

# AND logic: Concatenate horses and dogs with "&&" or handle empty/null
output "namespace_horses_and_logic" {
  value = { 
    for k, v in local.namespaces : 
    k => length(coalesce(lookup(v, "horses", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "horses", []), [])) : "no horses"
  }
}

output "namespace_dogs_and_logic" {
  value = { 
    for k, v in local.namespaces : 
    k => length(coalesce(lookup(v, "dogs", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "dogs", []), [])) : "no dogs"
  }
}

# Combining horses and dogs into a single output with AND logic for each
output "namespace_combined_horses_and_dogs" {
  value = {
    for k, v in local.namespaces : k => {
      horses = length(coalesce(lookup(v, "horses", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "horses", []), [])) : "no horses"
      dogs   = length(coalesce(lookup(v, "dogs", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "dogs", []), [])) : "no dogs"
    }
  }
}

resource "local_file" "output_json" {
  filename = "${path.module}/outputs.json"
  content  = replace(jsonencode({
    namespace_cats                = { for k, v in local.namespaces : k => coalesce(lookup(v, "cats", []), []) }
    namespace_horses_and_logic     = { for k, v in local.namespaces : k => length(coalesce(lookup(v, "horses", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "horses", []), [])) : "no horses" }
    namespace_dogs_and_logic       = { for k, v in local.namespaces : k => length(coalesce(lookup(v, "dogs", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "dogs", []), [])) : "no dogs" }
    namespace_combined_horses_dogs = {
      for k, v in local.namespaces : k => {
        horses = length(coalesce(lookup(v, "horses", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "horses", []), [])) : "no horses"
        dogs   = length(coalesce(lookup(v, "dogs", []), [])) > 0 ? join(" && ", coalesce(lookup(v, "dogs", []), [])) : "no dogs"
      }
    }
  }), "\\u0026", "&") # Replace the Unicode escape sequence with the actual "&"
}

