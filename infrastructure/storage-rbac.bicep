
param storageAccountName string = 'stenterpriseaiap26'
param identityName string = 'id-enterprise-ai'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: storageAccountName
}

resource aiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: identityName
}

// Allows the Functions host to manage Blob storage data.
var blobDataOwnerRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'
)

// Allows the Functions host to access Table storage data.
var tableDataContributorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
)

// Allows the identity to read and write deployment packages in Blob storage.
var blobDataContributorRoleId = subscriptionResourceId(
  'Microsoft.Authorization/roleDefinitions',
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
)

resource blobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, aiIdentity.id, blobDataOwnerRoleId)
  scope: storage
  properties: {
    roleDefinitionId: blobDataOwnerRoleId
    principalId: aiIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource tableRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, aiIdentity.id, tableDataContributorRoleId)
  scope: storage
  properties: {
    roleDefinitionId: tableDataContributorRoleId
    principalId: aiIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource deploymentBlobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storage.id, aiIdentity.id, blobDataContributorRoleId)
  scope: storage
  properties: {
    roleDefinitionId: blobDataContributorRoleId
    principalId: aiIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output assignedIdentity string = aiIdentity.name

output assignedRoles array = [
  'Storage Blob Data Owner'
  'Storage Table Data Contributor'
  'Storage Blob Data Contributor'
]
