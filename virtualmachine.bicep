
@secure()
param adminPassword string
param adminUsername string = 'azureuser'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: 'ijnetwork1'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
        ]
    }
}
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: 'ijnetwork1subnet1'
  parent: virtualNetwork
  properties: {
    addressPrefix: '10.0.0.0/24'
}
}

resource publicIP 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: 'ijpublicip1'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
      name: 'Standard'
      }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2024-03-01' = {
  name: 'ijnic1'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: 'ijvm1'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: '0001-com-ubuntu-server-jammy'
        sku: '22_04-lts-gen2'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    osProfile: {
      computerName: 'ijvm1'
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}
