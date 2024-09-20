### NEEDS MORE TESTING ###

resource "vault_jwt_auth_backend_role" "example_role" {
  for_each = local.namespaces

  role_name  = each.key
  user_claim = "value"
  bound_claims = {
    "ad" = each.value["ad-group"]

    # OR logic for cats: return the list as is
    "cats" = coalesce(lookup(each.value, "cats", []), [])

    # AND logic for horses: concatenate with "&&" or return "no horses" if empty
    "horses" = length(coalesce(lookup(each.value, "horses", []), [])) > 0 ? join(" && ", coalesce(lookup(each.value, "horses", []), [])) : "no horses"

    # AND logic for dogs: same as horses
    "dogs" = length(coalesce(lookup(each.value, "dogs", []), [])) > 0 ? join(" && ", coalesce(lookup(each.value, "dogs", []), [])) : "no dogs"
  }

  # Example of other required parameters for this resource
  token_policies = ["default"]
  token_ttl      = "1h"
  token_max_ttl  = "24h"
}
