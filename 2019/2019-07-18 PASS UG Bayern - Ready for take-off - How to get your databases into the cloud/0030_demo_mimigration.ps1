###############################################################################
#                              Andre Essing
# -----------------------------------------------------------------------------
## Developer.......: Andre Essing (https://github.com/aessing)
#                                (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
## -----------------------------------------------------------------------------
#	File:		0030_demo_mimigration.ps1
#
#	Summary:    This script creates the migration porject in DMS
#
#				THIS SCRIPT IS PART OF THE TRACK: Ready for take-off
#                                                 How to get your databases
#                                                 into the cloud
#
#	Date:		June 2019
#
#	SQL Server Version: 2008 / 2012 / 2014 / 2016 / 2017
# ----------------------------------------------------------------------------
#	Written by Andre Essing, Microsoft Deutschland GmbH
#
#	This script is intended only as a supplement to demos and lectures
#	given by Andre Essing.  
# 
#	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
#	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
#	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
#	PARTICULAR PURPOSE.
###############################################################################


# INSTALL DMS POWERSHELL MODULE
install-module Az.DataMigration -Force -AllowClobber

###############################################################################
# Prepare some stuff and login
###############################################################################

# DEFINE SOME VARIABLES
$subscriptionName = 'SUBSCRIPTION'
$region = 'northeurope'
$rgName = 'user-demo-dms-rg'
$vNetName = 'user-demo-dms-vnet01'
$subnetName = 'DMSSubnet'
$dmsName = 'user-demo-dms-dms01'
$dmsSKU = 'Premium_4vCores'
$projectName = "SQLMIMigration01"
$sourceServer = "172.16.6.4"
$sourceAuth = "SqlAuthentication"
$targetServer = "/subscriptions/f6c0b928-7078-4332-a106-e7a9c5253249/resourceGroups/user-demo-sqlmi-rg/providers/Microsoft.Sql/managedInstances/user-demo-sqlmi-sql01"
$dbname = "AdventureWorks2017"
$backupFileSharePath="\\172.16.6.4\Migration"
$storageResourceId = "/subscriptions/f6c0b928-7078-4332-a106-e7a9c5253249/resourceGroups/user-demo-dms-rg/providers/Microsoft.Storage/storageAccounts/userdemodmssto01"
$appId = "a7503a73-66dd-4b01-8e2f-4dabb01f92c8"
$appIdPwd = "jGSIMQyKczgk[W22LLmVcwuzt@01LP.+"

# LOGIN TO AZURE
Login-AzAccount
Select-AzSubscription -SubscriptionName  $subscriptionName


###############################################################################
# Create an instance of Azure Database Migration Service
###############################################################################

# CREATE RESSOURCE GROUP
New-AzResourceGroup -ResourceGroupName $rgName -Location $region

# CREATE DMS SERVICE
$vNet = Get-AzVirtualNetwork -ResourceGroupName $rgName -Name $vNetName
$vSubNet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vNet -Name $subnetName
$dmsService = New-AzDms -ResourceGroupName $rgName -ServiceName $dmsName -Location $region -Sku $dmsSKU -VirtualSubnetId $vSubNet.Id 
#$dmsService = Get-AzDms -ResourceGroupName $rgName -ServiceName $dmsName


###############################################################################
# Create a migration project
###############################################################################

# CREATE DATABASE CONNECTION INFO FOR SOURCE
$sourceConnInfo = New-AzDmsConnInfo -ServerType SQL -DataSource $sourceServer -AuthType $sourceAuth -TrustServerCertificate:$true
$sourceCred = Get-Credential

# CREATE DATABASE CONNECTION INFO FOR TARGET
$targetConnInfo = New-AzDmsConnInfo -ServerType SQLMI -MiResourceId $targetServer
$targetCred = Get-Credential

# CREATE MIGRATION PROJECT
$project = New-AzDataMigrationProject -ResourceGroupName $rgName -ServiceName $dmsService.Name -ProjectName $projectName -Location $region -SourceType SQL -TargetType SQLMI 


###############################################################################
# Create and start a migration task
###############################################################################

# CREATE BACKUP FILESHARE OBJECT
$backupCred = Get-Credential
$backupFileShare = New-AzDmsFileShare -Path $backupFileSharePath -Credential $backupCred

# CREATE DB OBJECT FOR SINGLE DATABASE
$selectedDbs = @()
$selectedDbs += New-AzDmsSelectedDB -MigrateSqlServerSqlDbMi -Name $dbname -TargetDatabaseName $dbname -BackupFileShare $backupFileShare

# CONFIGURE AZURE ACTIVE DIRECTORY APP
$AppPasswd = ConvertTo-SecureString $appIdPwd -AsPlainText -Force
$app = New-AzDmsAadApp -ApplicationId $appId -AppKey $AppPasswd

# CREATE FULL BACKUP

# CREATE AND START ONLINE MIGRATION
New-AzDataMigrationTask -TaskType MigrateSqlServerSqlDbMiSync `
    -ResourceGroupName $rgName `
    -ServiceName $dmsService.Name `
    -ProjectName $project.Name `
    -TaskName $dbname `
    -SourceConnection $sourceConnInfo `
    -SourceCred $sourceCred `
    -TargetConnection $targetConnInfo `
    -TargetCred $targetCred `
    -SelectedDatabase  $selectedDbs `
    -BackupFileShare $backupFileShare `
    -AzureActiveDirectoryApp $app `
    -StorageResourceId $storageResourceId


###############################################################################
# EOF