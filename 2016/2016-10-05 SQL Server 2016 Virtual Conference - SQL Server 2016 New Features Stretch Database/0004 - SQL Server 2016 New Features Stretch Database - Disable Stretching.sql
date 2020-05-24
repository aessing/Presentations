/* ============================================================================
                          Trivadis GmbH - Andre Essing
-------------------------------------------------------------------------------

 Developer.......: Andre Essing (https://github.com/aessing)
                                (https://twitter.com/aessing)
                                (https://www.linkedin.com/in/aessing/)

 Summary......: Powershell demo script for session
                SQL Server 2016 New Features Stretch Database
                Disable stretching to Azure
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
-- Drop a table that has stretching enabled (Doesn't delete data in the cloud)
-------------------------------------------------------------------------------
DROP TABLE [Sales].[OrderTrackingDemoDrop];
GO


-------------------------------------------------------------------------------
-- Before stretching for Sales.OrderTracking table is disabled execute
-- sp_SpaceUsed to view amount of data stored in Sales.OrderTracking.  
--
-- 0 / 71542 rows
--
-- Original table data:
-- 188790 rows
-------------------------------------------------------------------------------
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'LOCAL_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'REMOTE_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'ALL';
EXEC [sys].[sp_spaceused] 'Sales.OrderTrackingDemo', 'true', 'LOCAL_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTrackingDemo', 'true', 'REMOTE_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTrackingDemo', 'true', 'ALL';
GO

-------------------------------------------------------------------------------
-- Disable stretching for [Sales].[OrderTracking] table and migrate cloud data
-- into the on premise table. The process can not be canceled.
-------------------------------------------------------------------------------
ALTER TABLE [Sales].[OrderTracking]
   SET ( REMOTE_DATA_ARCHIVE ( MIGRATION_STATE = INBOUND ) ) ;
GO

ALTER TABLE [Sales].[OrderTrackingDemo]
   SET ( REMOTE_DATA_ARCHIVE = OFF_WITHOUT_DATA_RECOVERY ( MIGRATION_STATE = PAUSED ) ) ;
GO


-------------------------------------------------------------------------------
-- After enabling a table for stretching, you can monitor the migration process
-- to the cloud in a new Dynamic Management View (DMV)
-------------------------------------------------------------------------------
SELECT * FROM [sys].[dm_db_rda_migration_status] ORDER BY [start_time_utc] DESC;
GO


------------------------------------------------------------------------------
-- After stretching for Sales.OrderTracking table is disabled execute
-- sp_SpaceUsed to view amount of data stored in Sales.OrderTracking.  
--
-- ATTENTION: Throws an error
--
-- 0 / 71542 rows
--
-- Original table data:
-- 188790 rows
-------------------------------------------------------------------------------
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'LOCAL_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'REMOTE_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'ALL';
EXEC [sys].[sp_spaceused] 'Sales.OrderTrackingDemo', 'true', 'LOCAL_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTrackingDemo', 'true', 'REMOTE_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTrackingDemo', 'true', 'ALL';
GO


-------------------------------------------------------------------------------
-- When all data is moved back into the on premise database, streching can
-- turned off completely for the database
-------------------------------------------------------------------------------
ALTER DATABASE [AdventureWorks2016CTP3]
	SET REMOTE_DATA_ARCHIVE = OFF;
GO


-------------------------------------------------------------------------------
-- Clean the kitchen
-------------------------------------------------------------------------------
DROP FUNCTION [dbo].[fn_OrderTrackingDemo_StretchPredicate];
DROP TABLE [Sales].[OrderTrackingDemo];
DROP DATABASE SCOPED CREDENTIAL [CRED_StretchDB];
DROP MASTER KEY;
GO

EXEC [sys].[sp_configure] 'remote data archive' , '0';
GO
RECONFIGURE;s
GO
