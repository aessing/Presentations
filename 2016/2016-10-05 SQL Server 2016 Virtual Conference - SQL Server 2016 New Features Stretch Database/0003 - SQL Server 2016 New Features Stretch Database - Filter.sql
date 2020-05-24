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
-- When the database is enabled for stretching, migrate a whole table with
-- Stretched Database to the Azure cloud
-------------------------------------------------------------------------------
ALTER TABLE [Sales].[OrderTracking]
    SET ( REMOTE_DATA_ARCHIVE = ON ( MIGRATION_STATE = OUTBOUND ) );
GO


-------------------------------------------------------------------------------
-- After enabling a table for stretching, you can monitor the migration process
-- to the cloud in a new Dynamic Management View (DMV)
-------------------------------------------------------------------------------
SELECT * FROM [sys].[dm_db_rda_migration_status] ORDER BY [start_time_utc] DESC;
GO


-------------------------------------------------------------------------------
-- After stretching the Sales.OrderTracking table in the AdventureWorks2016CTP3
-- database Execute sp_SpaceUsed to view amount of data stored LOCAL_ONLY,
-- REMOTE_ONLY and ALL data combined.  
--
-- 188790 rows
-------------------------------------------------------------------------------
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'LOCAL_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'REMOTE_ONLY';
EXEC [sys].[sp_spaceused] 'Sales.OrderTracking', 'true', 'ALL';
GO


-------------------------------------------------------------------------------
-- It is also possible to create a table directly that is stretched to the cloud
-------------------------------------------------------------------------------
CREATE TABLE [Sales].[OrderTrackingDemoDrop] (
	[OrderTrackingID] [INT] NOT NULL,
	[SalesOrderID] [INT] NOT NULL,
	[CarrierTrackingNumber] [NVARCHAR](25) NULL,
	[TrackingEventID] [INT] NOT NULL,
	[EventDetails] [NVARCHAR](2000) NOT NULL,
	[EventDateTime] [DATETIME2](7) NOT NULL,
) WITH ( REMOTE_DATA_ARCHIVE = ON ( MIGRATION_STATE = OUTBOUND ) ) ;
GO


-------------------------------------------------------------------------------
-- Lets have a look at filtered stretching
--
-- To start here, we first need to prepare a table with data in it
-------------------------------------------------------------------------------
CREATE TABLE [Sales].[OrderTrackingDemo] (
	[OrderTrackingID] [INT] NOT NULL,
	[SalesOrderID] [INT] NOT NULL,
	[CarrierTrackingNumber] [NVARCHAR](25) NULL,
	[TrackingEventID] [INT] NOT NULL,
	[EventDetails] [NVARCHAR](2000) NOT NULL,
	[EventDateTime] [DATETIME2](7) NOT NULL,
);
GO

INSERT INTO [Sales].[OrderTrackingDemo]
	SELECT * FROM [Sales].[OrderTracking];
GO


-------------------------------------------------------------------------------
-- To filter data that is stretched to the cloud, you have to create a filter
-- predicate, which is a schema bound funtion
-------------------------------------------------------------------------------
CREATE FUNCTION [dbo].[fn_OrderTrackingDemo_StretchPredicate](@column1 DATETIME2)
RETURNS TABLE
WITH SCHEMABINDING 
AS 
RETURN	SELECT 1 AS [is_eligible]
		WHERE @column1 < CONVERT(DATETIME, '1/1/2014', 101);
GO


-------------------------------------------------------------------------------
-- Now check the function if the filter predicate works
-------------------------------------------------------------------------------
SELECT TOP 100 * FROM [Sales].[OrderTrackingDemo] ORDER BY [EventDateTime] DESC;
GO
SELECT TOP 100 * FROM [Sales].[OrderTrackingDemo] CROSS APPLY [dbo].[fn_OrderTrackingDemo_StretchPredicate]([EventDateTime]) ORDER BY [EventDateTime] DESC;
GO
 

-------------------------------------------------------------------------------
-- When everything is fine, you can enable the stretching of the table. Just
-- add a FILTER_PREDICATE to filter the stretching and keep some data localy
-------------------------------------------------------------------------------
ALTER TABLE [Sales].[OrderTrackingDemo]
	SET ( REMOTE_DATA_ARCHIVE = ON ( FILTER_PREDICATE = dbo.fn_OrderTrackingDemo_StretchPredicate(EventDateTime), MIGRATION_STATE = OUTBOUND ) );
GO
