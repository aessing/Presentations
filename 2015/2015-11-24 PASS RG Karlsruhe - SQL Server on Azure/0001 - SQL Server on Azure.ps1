# =============================================================================
#                               Andre Essing
# -----------------------------------------------------------------------------
#
# Developer.......: Andre Essing (https://github.com/aessing)
#                                (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
#
# Summary......: Powershell demo script for talk
#                SQL Server on Azure - Best Practices für den DB Server in der Cloud
# Date.........: 18.11.2015
# Version......: 01.00.00
#
# -----------------------------------------------------------------------------
#
# Copyright (C) 2015 Andre Essing. All rights reserverd.
#
# For more scripts and sample code, check out http://www.andreessing.de/
#
# You may alter this code for your own 'non-commercial' purposes. You may
# republish altered code as long as you include this copyright and give due
# credit.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
# -----------------------------------------------------------------------------
#
# Changes:
# DD.MM.YYYY    Developer       Version     Reason
# 18.11.2015    Andre Essing    01.00.00    Initial Release
#
# =============================================================================



# ######### SETUP #############################################################
$AzureSubscriptionName = "PTSP Azure Pass"

$RessourceGroupName = "PASS-Test-RG01"
$LocationName = "West Europe"
$Tags =  @{Name="Type";Value="Demo"}, @{Name="Reason";Value="PASS Talk"}, @{Name="Location";Value="PASS RG Karlsruhe"}

$StorageAccountName = "passteststore01"

$SubnetName = "PASS-Test-SUBNET01"
$NetworkName = "PASS-Test-NET01"
$PublicIPName = "PASS-Test-PIP01"
$NICName = "PASS-TEST-NIC01"
$DNSName = "passtestsrv01"

$VMName = "PASS-TEST-SRV01"
$OSDiskName = $VMName + "_OSDisk"
$DataDiskName = $VMName + "_DataDisk01"

$AccessPolicyName = "passtestaccesspolicy"
$DBContainerName = "databases"
$BackupContainerName = "sqlbackups"



# ######### CONNECT ###########################################################
# Login to Azure with Microsoft Account (Ressource Model)
Login-AzureRmAccount

# Select the subscription you want to use
Select-AzureRmSubscription -SubscriptionName $AzureSubscriptionName 



# ######### DEMO 1 ############################################################
# Create new resource group for demo
New-AzureRmResourceGroup -Name $RessourceGroupName -Location $LocationName -Tag $Tags

# Create new Storage Accounts
New-AzureRmStorageAccount -ResourceGroupName $RessourceGroupName -Name $StorageAccountName -Location $LocationName -Tags $Tags -Type Standard_LRS



# ########## DEMO 2 ############################################################
# Get key for storage account
$Storagekeys = Get-AzureRmStorageAccountKey -ResourceGroupName $RessourceGroupName -Name $StorageAccountName

# Create a container in blob storage
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Storagekeys.Key1
New-AzureStorageContainer -Name $DBContainerName -Context $StorageContext


# Set up a Stored Access Policy and a Shared Access Signature for the new container
$StorageContainer = Get-AzureStorageContainer -Name $DBContainerName -Context $StorageContext
$CloudBlobContainer = $StorageContainer.CloudBlobContainer

$Permissions = $CloudBlobContainer.GetPermissions()
$AccessPolicy = new-object 'Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPolicy'
$AccessPolicy.SharedAccessStartTime = $(Get-Date).ToUniversalTime().AddHours(-1)
$AccessPolicy.SharedAccessExpiryTime = $(Get-Date).ToUniversalTime().AddYears(10)
$AccessPolicy.Permissions = "Read,Write,List,Delete"
$Permissions.SharedAccessPolicies.Add($AccessPolicyName, $AccessPolicy)
$CloudBlobContainer.SetPermissions($permissions);

# Get the Shared Access Signature for the policy
$AccessPolicy = new-object 'Microsoft.WindowsAzure.Storage.Blob.SharedAccessBlobPolicy'
$CloudBlobContainer.GetSharedAccessSignature($AccessPolicy, $AccessPolicyName)

# The journey continues in SSMS - 0010 - SQL Server on Azure.sql

# Get blobs in storage
Get-AzureStorageBlob -Context $StorageContext -Container $DBContainerName;



# ######### DEMO 3 ############################################################
# Create network
$Subnet = New-AzureRMVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix 172.16.201.0/24
New-AzureRMVirtualNetwork -Name $NetworkName -ResourceGroupName $RessourceGroupName -Location $LocationName -Subnet $Subnet -Tag $Tags -AddressPrefix 172.16.201.0/18

# Create virtual machine network interface
$Network = Get-AzureRMVirtualNetwork -Name $NetworkName -ResourceGroupName $RessourceGroupName
$PublicIP = New-AzureRMPublicIpAddress -Name $PublicIPName -ResourceGroupName $RessourceGroupName -Location $LocationName -Tag $Tags -DomainNameLabel $DNSName -AllocationMethod Dynamic
$NIC = New-AzureRMNetworkInterface -Name $NICName -ResourceGroupName $RessourceGroupName -Location $LocationName -Tag $Tags -SubnetId $Network.Subnets[0].Id -PublicIpAddressId $PublicIP.Id

# Create virtual machine config
$StorageAccount = Get-AzureRMStorageAccount -ResourceGroupName $RessourceGroupName -Name $StorageAccountName
$OSDiskUrl = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $VMName + "_OSDisk.vhd"

$LocalAdminCred = Get-Credential -Message "Type the name and password of the local administrator of the vm" 

$VMConfig = New-AzureRMVMConfig -VMName $VMName -VMSize Standard_A2
$VMConfig = Set-AzureRMVMOperatingSystem -VM $VMConfig -Windows -ComputerName $VMName -Credential $LocalAdminCred -ProvisionVMAgent -EnableAutoUpdate 
$VMConfig = Set-AzureRMVMSourceImage -VM $VMConfig -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
$VMConfig = Add-AzureRMVMNetworkInterface -VM $VMConfig -Id $NIC.Id
$VMConfig = Set-AzureRMVMOSDisk -VM $VMConfig -Name $OSDiskName -VhdUri $OSDiskUrl -CreateOption fromImage

# Create virtual machine
New-AzureRMVM -ResourceGroupName $RessourceGroupName -Location $LocationName -VM $VMConfig -Tags $Tags



# ######### DEMO 4 ############################################################
# Add a disk to the server
$DataDiskUrl = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $VMName + "_DataDisk01.vhd"
$VM = get-AzureRMVM -ResourceGroupName $RessourceGroupName -Name $VMName

Add-AzureRmVMDataDisk -VM $VM -Name $DataDiskName -DiskSizeInGB 256 -VhdUri $DataDiskUrl -Caching None -CreateOption empty -Lun 1
Update-AzureRmVM -VM $VM -ResourceGroupName $RessourceGroupName 



# ######### DEMO 5 ############################################################
# Get key for storage account
$Storagekeys = Get-AzureRmStorageAccountKey -ResourceGroupName $RessourceGroupName -Name $StorageAccountName
$Storagekeys.Key1.ToString()

# Create a container in blob storage
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $Storagekeys.Key1
New-AzureStorageContainer -Name $BackupContainerName -Context $StorageContext

# The journey continues in SSMS 0010 - SQL Server on Azure.sql

# Get blobs in storage
Get-AzureStorageBlob -Context $StorageContext -Container $BackupContainerName;



# ######### Clean up devils kitchen ###########################################
$VM = get-AzureRMVM -ResourceGroupName $RessourceGroupName -Name $VMName
Remove-AzureRmVMDataDisk -VM $VM -DataDiskNames $DataDiskName
Update-AzureRmVM -VM $VM -ResourceGroupName $RessourceGroupName 

Remove-AzureRmVM -Name $VMName -ResourceGroupName $RessourceGroupName -Force

Remove-AzureRMNetworkInterface  -Name $NICName -ResourceGroupName $RessourceGroupName -Force
Remove-AzureRMPublicIpAddress -Name $PublicIPName -ResourceGroupName $RessourceGroupName -Force
Remove-AzureRMVirtualNetwork -Name $NetworkName -ResourceGroupName $RessourceGroupName -Force

Remove-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $RessourceGroupName

Remove-AzureRmResourceGroup -Name $RessourceGroupName -Force
