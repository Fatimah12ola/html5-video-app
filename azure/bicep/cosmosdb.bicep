param location string = resourceGroup().location
param accountName string = 'your-cosmosdb-account-name'
param databaseName string = 'your-database-name'
param containerName string = 'your-container-name'

resource cosmosDb 'Microsoft.DocumentDB/databaseAccounts@2021-03-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2021-03-15' = {
  name: databaseName
  parent: cosmosDb
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2021-03-15' = {
  name: containerName
  parent: database
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
      }
    }
  }
}

output cosmosDbAccountEndpoint string = cosmosDb.properties.documentEndpoint
output cosmosDbAccountPrimaryKey string = listKeys(cosmosDb.id, '2021-03-15').primaryMasterKey