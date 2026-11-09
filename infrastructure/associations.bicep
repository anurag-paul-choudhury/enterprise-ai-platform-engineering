
param vnetName string = 'vnet-enterprise-ai'
param appNsgName string = 'nsg-app'
param managementNsgName string = 'nsg-management'

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' existing = {
  name: vnetName
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' existing = {
  name: appNsgName
}

resource managementNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' existing = {
  name: managementNsgName
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: 'snet-app'
  properties: {
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroup: {
      id: appNsg.id
    }
  }
}

resource managementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: 'snet-management'
  properties: {
    addressPrefix: '10.0.3.0/24'
    networkSecurityGroup: {
      id: managementNsg.id
    }
  }
}
