#Check eerst de subscription deployment
Get-AzSubscriptionDeploymentStack

#verwijder de subscription deployment
#ga eerst naar de subscription waar de deployment is gemaakt
Set-AzContext -SubscriptionId "642c5145-e484-4ffa-987b-50c8d7ec7fff"

#verwijder met onderstaande commando
Remove-AzSubscriptionDeploymentStack `
  -Name "networking-hubnetworking" `
  -ActionOnUnmanage DeleteAll `
  -Force

  #kan lang duren voordat alles verwijderd is, check of gestart is.

  Set-AzContext -SubscriptionId "642c5145-e484-4ffa-987b-50c8d7ec7fff"

Get-AzSubscriptionDeploymentStack -Name "networking-hubnetworking" |
  Select Name, ProvisioningState, CorrelationId, DeploymentId, CreationTime


  Get-AzManagementGroupDeploymentStack -ManagementGroupId alz

 Remove-AzManagementGroupDeploymentStack `
  -ManagementGroupId "alz" `
  -Name "governance-int-root" `
  -ActionOnUnmanage DeleteAll `
  -Force