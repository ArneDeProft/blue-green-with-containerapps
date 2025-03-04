param environmentName string
param redisName string = 'rds-${environmentName}'
param location string = resourceGroup().location
param logAnalyticsCustomerId string
param logAnalyticsSharedKey string
param appInsightsInstrumentationKey string
param internalOnly bool

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: 'vnet-${resourceGroup().name}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/19'
      ]
    }
    subnets: [
      {
        name: 'gateway'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'jumpbox'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'apim'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
        }
      }
      {
        name: 'aca-control'
        properties: {
          addressPrefix: '10.0.8.0/21'
        }
      }
      {
        name: 'aca-apps'
        properties: {
          addressPrefix: '10.0.16.0/21'
        }
      }
    ]
  }
}


resource redisCache 'Microsoft.Cache/Redis@2019-07-01' = {
  name: redisName
  location: resourceGroup().location
  properties: {
    enableNonSslPort: true
    sku: {
      name: 'Basic'
      family: 'C'
      capacity: 0
    }
  }
}


resource environment 'Microsoft.App/managedEnvironments@2022-01-01-preview' = {
  name: environmentName
  location: location
  properties: {
    type: 'managed'
    internalLoadBalancerEnabled: false
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsCustomerId
        sharedKey: logAnalyticsSharedKey
      }
    }
    containerAppsConfiguration: {
      daprAIInstrumentationKey: appInsightsInstrumentationKey
      controlPlaneSubnetResourceId : '${vnet.id}/subnets/aca-control'
      appSubnetResourceId: '${vnet.id}/subnets/aca-apps'
      internalOnly: internalOnly
    }
  }
}

output location string = location
output environmentId string = environment.id
