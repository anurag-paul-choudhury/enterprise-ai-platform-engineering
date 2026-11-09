targetScope = 'resourceGroup'

// Core infrastructure
module network 'network.bicep' = {
  name: 'network-deployment'
}

module identity 'identity.bicep' = {
  name: 'identity-deployment'
}

module security 'security.bicep' = {
  name: 'security-deployment'
}

module keyVault 'keyvault.bicep' = {
  name: 'keyvault-deployment'
}

module storage 'storage.bicep' = {
  name: 'storage-deployment'
}

// Network associations depend on the VNet and NSGs.
module associations 'associations.bicep' = {
  name: 'associations-deployment'
  dependsOn: [
    network
    security
  ]
}

// Key Vault permissions depend on the identity and vault.
module keyVaultRbac 'keyvault-rbac.bicep' = {
  name: 'keyvault-rbac-deployment'
  dependsOn: [
    identity
    keyVault
  ]
}

// Storage permissions depend on the identity and storage account.
module storageRbac 'storage-rbac.bicep' = {
  name: 'storage-rbac-deployment'
  dependsOn: [
    identity
    storage
  ]
}