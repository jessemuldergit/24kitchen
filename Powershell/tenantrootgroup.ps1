# Delete role assignmenst tenant root group
# c0318375-d347-47ea-9c08-8f51a924b7e4 is Owner role assignment for tenant root group
Remove-AzRoleAssignment -Scope "/" -RoleDefinitionId "38863829-c2a4-4f8d-b1d2-2e325973ebc7" -ObjectId "c0318375-d347-47ea-9c08-8f51a924b7e4"

# Is for getting all role assignments for tenant root group
Get-AzRoleAssignment -scope /