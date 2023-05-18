param fwPolicyName string = ''

param sytemRequiredOutboundFqdns array = [
  '*.msappproxy.net'
  '*.servicebus.windows.net'
  'crl3.digicert.com'
  'crl4.digicert.com'
  'ocsp.digicert.com'
  'crl.microsoft.com'
  'oneocsp.microsoft.com'
  'ocsp.msocsp.com'
  'login.windows.net'
  'secure.aadcdn.microsoftonline-p.com'
  '*.microsoftonline.com'
  '*.microsoftonline-p.com'
  '*.msauth.net'
  '*.msauthimages.net'
  '*.msecnd.net'
  '*.msftauth.net'
  '*.msftauthimages.net'
  '*.phonefactor.net'
  'enterpriseregistration.windows.net'
  'management.azure.com'
  'policykeyservice.dc.ad.msft.net'
  'ctldl.windowsupdate.com'
  'kms.core.windows.net'
  '*.blob.core.windows.net'
  '*.aadconnecthealth.azure.com'
  '*.adhybridhealth.azure.com'
  '*.office.com'
  'aadcdn.msftauth.net'
  'aadcdn.msauth.net'
]

param azureSiteRecoveryOutboundFqdns array = [
  'login.microsoftonline.com'
  '*.vault.azure.net'
  '*automation.ext.azure.com'
  '*hypervrecoverymanager.windowsazure.com'
]

resource fwPolicy 'Microsoft.Network/firewallPolicies@2022-11-01' existing = {
  name: fwPolicyName
  }

resource fwpolicyCoreApplicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-11-01' = {
  parent: fwPolicy
  name: 'CoreApplicationRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        name: 'Microsoft-Outbound-Rules'
        priority: 100
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'WindowsUpdates'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: [
              'WindowsUpdate'
            ]
            webCategories: []
            targetFqdns: []
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
            httpHeadersToInsert: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'SystemRequired_Outbound'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: sytemRequiredOutboundFqdns
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
            httpHeadersToInsert: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AzureSiteRecovery_Outbound'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            fqdnTags: []
            webCategories: []
            targetFqdns: azureSiteRecoveryOutboundFqdns
            targetUrls: []
            terminateTLS: false
            sourceAddresses: [
              '*'
            ]
            destinationAddresses: []
            sourceIpGroups: []
            httpHeadersToInsert: []
          }
        ]
      }
    ]
  }
}

resource fwpolicyCoreDNATRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-11-01' = {
  parent: fwPolicy
  name: 'CoreDNATRuleCollectionGroup'
  dependsOn: [
  fwpolicyCoreApplicationRuleCollectionGroup
]
properties: {
  priority: 300
  ruleCollections: []
}
}

resource fwpolicyCoreNetworkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2022-11-01' = {
  parent: fwPolicy
  name: 'CoreNetworkRuleCollectionGroup'
  dependsOn:[
    fwpolicyCoreDNATRuleCollectionGroup
  ]
  properties: {
    priority: 100
    ruleCollections: [
      {
        name: 'Internet-Outbound-Allow'
        priority: 200
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'Internet-Outbound-Allow'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '80'
              '443'
              '1688'
              '5671'
            ]
          }
        ]
        }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        action: {
          type: 'Allow'
        }
        name: 'DNS-Outbound-Allow'
        priority: 100
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'DNS-Outbound-Allow'
            ipProtocols: [
              'TCP'
              'UDP'
            ]
            sourceAddresses: [
              '*'
            ]
            sourceIpGroups: []
            destinationAddresses: [
              '*'
            ]
            destinationIpGroups: []
            destinationFqdns: []
            destinationPorts: [
              '53'
            ]
          }
        ]
      }
    ]
  }
}
