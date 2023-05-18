//Get Location of resources from location of Resource Group
param location string = resourceGroup().location

@description('Tags. CreatedBy must be declared when run')
param CreatedBy string = ''
@allowed(['Production','Test','Training','Development'])
param Purpose string = ''
@allowed(['DDaT','Place','People','Service Reform'])
param MgtArea string = ''

param vnetRG string = ''
param vnetName string = ''
param subnetName string = 'AzureFirewallSubnet'
param publicIp string = ''
param fwPolicyName string = ''
param fwName string = ''

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
