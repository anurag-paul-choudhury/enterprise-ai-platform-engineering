
param location string = resourceGroup().location

resource aiManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'id-enterprise-ai'
  location: location
}

output identityName string = aiManagedIdentity.name
output identityId string = aiManagedIdentity.id
output principalId string = aiManagedIdentity.properties.principalId
output clientId string = aiManagedIdentity.properties.clientId
