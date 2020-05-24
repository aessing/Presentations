# =============================================================================
#                              Andre Essing
# -----------------------------------------------------------------------------
#
# Developer.......: Andre Essing (https://github.com/aessing)
#                                (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
#
# Summary......: Powershell demo script for session
#                SQL Server 2016 New Features Stretch Database
#                Create the SQL Azure Database for use as Stretched Database
# Date.........: 25.04.2016
# Version......: 01.00.00
#
# -----------------------------------------------------------------------------
#
# Copyright (C) 2016 Andre Essing. All rights reserverd.
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
# 25.04.2016    Andre Essing    01.00.00    Initial Release
#
# =============================================================================


## SQL Azure DATABASE SERVER NAME = tvdaessql2016demosql01.database.windows.net
## SQL Azure DATABASE USERNAME = DemoSA
## SQL Azure DATABASE PASSWORD = Pa$$w0rd


###############################################################################
# Login to Azure with Microsoft Account (Ressource Model)
Login-AzureRmAccount

# Select the subscription you want to use
Select-AzureRmSubscription -SubscriptionName "TVD-VSEMSDN" 

# Create new resource group for demo
$AzrRscGrp = New-AzureRmResourceGroup -Name "tvdaessql2016demo" -Location "West Europe"

# Create an Azure SQL Database
$AzrSQLCrd = new-object System.Management.Automation.PSCredential("DemoSA", ('Pa$$w0rd'  | ConvertTo-SecureString -asPlainText -Force))
$AzrSQLSrv = New-AzureRmSqlServer -ServerName "tvdaessql2016demosql01" -ServerVersion "12.0" -SqlAdministratorCredentials $AzrSQLCrd -Location "West Europe" -ResourceGroupName $AzrRscGrp.ResourceGroupName
New-AzureRmSqlServerFirewallRule -FirewallRuleName "AllowAny" -StartIpAddress "0.0.0.0" -EndIpAddress "255.255.255.255" -ServerName $AzrSQLSrv.ServerName -ResourceGroupName $AzrRscGrp.ResourceGroupName


###############################################################################
## Clean the kitchen
Remove-AzureRmResourceGroup -Name $AzrRscGrp.ResourceGroupName -Force
