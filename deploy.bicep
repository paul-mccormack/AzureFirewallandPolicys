//Get Location of resources from location of Resource Group
param location string = resourceGroup().location

@description('Tags. CreatedBy must be declared when run')
param CreatedBy string = 'Paul McCormack'
@allowed(['Production','Test','Training','Development'])
param Purpose string = 'Production'
@allowed(['DDaT','Place','People','Service Reform'])
param MgtArea string = 'DDaT'

param vnetRG string = 'rg-uks-connectivity-network'
param vnetName string = 'vnet-uks-connectivity-hub'
param subnetName string = 'AzureFirewallSubnet'
param publicIp string = 'pip-afw-uks-hub-01'
param fwPolicyName string = 'fwpol-connectivity-hub'
param fwName string = 'afw-uks-conectivity-hub-01'

resource afwSubnet 'Microsoft.Network/virtualNetworks/subnets@2022-11-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: resourceGroup(vnetRG)
}

resource afwPublicIp 'Microsoft.Network/publicIPAddresses@2022-11-01' = {
  name: publicIp
  location: location
  sku:{
    name: 'Standard'
  }
  tags:{
    CreatedBy: CreatedBy
    Purpose: Purpose
    MgtArea: MgtArea
  }
  properties:{
    publicIPAddressVersion:'IPv4'
    publicIPAllocationMethod:'Static'
  }
}

resource fwPolicy 'Microsoft.Network/firewallPolicies@2022-11-01' = {
  name: fwPolicyName
  location: location
  tags:{
    CreatedBy: CreatedBy
    Purpose: Purpose
    MgtArea: MgtArea
  }
  properties:{
    sku:{
    tier:'Standard'
    }
    threatIntelMode:'Deny'
    snat:{
      privateRanges:[
        '172.20.0.0/16'
      ]
    }
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2022-11-01' = {
  name: fwName
  location: location
  tags:{
    CreatedBy: CreatedBy
    Purpose: Purpose
    MgtArea: MgtArea
  }
  properties:{
    ipConfigurations:[
      {
        name: 'ipconfig1'
        properties:{
          subnet: {
            id: afwSubnet.id
          }
          publicIPAddress:{
            id: afwPublicIp.id
          }
        }
      }
    ]
    sku:{
      tier: 'Standard'
    }
    firewallPolicy:{
      id: fwPolicy.id
    }
  }
}
