/* ============================================================================
                          Trivadis GmbH - Andre Essing
-------------------------------------------------------------------------------
 
 Developer.......: Andre Essing (https://github.com/aessing)
                                (https://twitter.com/aessing)
                                (https://www.linkedin.com/in/aessing/)

 Summary......: Powershell demo script for session
                SQL Server 2016 New Features Stretch Database
                Enable stretching to Azure
 Date.........: 25.04.2016
 Version......: 01.00.00

-------------------------------------------------------------------------------

 Copyright (C) 2016 Andre Essing. All rights reserverd.

 You may alter this code for your own 'non-commercial' purposes. You may
 republish altered code as long as you include this copyright and give due
 credit.

 THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, 
 EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.

-------------------------------------------------------------------------------

 Changes:
 DD.MM.YYYY    Developer       Version     Reason
 25.04.2016    Andre Essing    01.00.00    Initial Release

=============================================================================*/

USE [AdventureWorks2016CTP3];
GO

-------------------------------------------------------------------------------
-- Before stretching the Sales.OrderTracking table in the AdventureWorks2016CTP3
-- database Execute sp_SpaceUsed to view amount of data stored in Sales.OrderTracking.  
--
-- 188790 rows
-------------------------------------------------------------------------------
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking';
GO


-------------------------------------------------------------------------------
-- Start with stretching
-- Enable Stretch Database on instance level
-------------------------------------------------------------------------------
EXEC [sys].[sp_configure] 'remote data archive' , '1';
GO
RECONFIGURE;
GO


-------------------------------------------------------------------------------
-- Create a database master key to secure the Azure SQL Database credentials
-------------------------------------------------------------------------------
CREATE MASTER KEY ENCRYPTION BY PASSWORD='Pa$$w0rd';
GO


-------------------------------------------------------------------------------
-- Create a credential to connect to Azure SQL Database Server
-------------------------------------------------------------------------------
CREATE DATABASE SCOPED CREDENTIAL [CRED_StretchDB]
	WITH IDENTITY = 'DemoSA'
	   , SECRET = 'Pa$$w0rd';
GO

SELECT * FROM [sys].[database_scoped_credentials]
GO


-------------------------------------------------------------------------------
-- Enable the AdvantureWorks2016 database for Stretched Database and connect
-- it with the credentials to the Azure SQL Database (Takes some time)
-------------------------------------------------------------------------------
ALTER DATABASE [AdventureWorks2016CTP3]
	SET REMOTE_DATA_ARCHIVE = ON (
	    SERVER = 'tvdaessql2016demosql01.database.windows.net'
	  , CREDENTIAL = [CRED_StretchDB] );
GO
