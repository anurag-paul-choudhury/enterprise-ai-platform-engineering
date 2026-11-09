
param keyVaultName string = 'kv-enterprise-ai-ap-2026'
param identityName string = 'id-enterprise-ai'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource aiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

var secretsUserRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '4633458b-17de-408a-b874-0445c86b69e6'
)

resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, aiIdentity.id, secretsUserRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: secretsUserRoleId
    principalId: aiIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output assignedRole string = 'Key Vault Secrets User'
output assignedIdentity string = aiIdentity.name
