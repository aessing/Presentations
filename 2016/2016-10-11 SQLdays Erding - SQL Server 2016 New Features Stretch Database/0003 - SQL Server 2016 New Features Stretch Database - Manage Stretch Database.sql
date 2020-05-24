/* ============================================================================
                          Trivadis GmbH - Andre Essing
-------------------------------------------------------------------------------

 Developer.......: Andre Essing (https://github.com/aessing)
                                (https://twitter.com/aessing)
                                (https://www.linkedin.com/in/aessing/)

 Summary......: SQL demo script for session
                SQL Server 2016 New Features Stretch Database
                Manage the stretching of databases
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
-- Pause data migration
-------------------------------------------------------------------------------
ALTER TABLE [Sales].[OrderTracking]
    SET ( REMOTE_DATA_ARCHIVE ( MIGRATION_STATE = PAUSED ) ) ;
GO


-------------------------------------------------------------------------------
-- Get info about local databases and tables enabled for Stretch Database
-------------------------------------------------------------------------------
SELECT [name], [is_remote_data_archive_enabled]
FROM   [sys].[databases]
WHERE  [is_remote_data_archive_enabled] = 1;

SELECT [name], [is_remote_data_archive_enabled]
FROM   [sys].[tables]
WHERE  [is_remote_data_archive_enabled] = 1;
GO


-------------------------------------------------------------------------------
-- Get info about remote databases and tables used by Stretch Database
-------------------------------------------------------------------------------
SELECT * FROM [sys].[remote_data_archive_databases];
SELECT * FROM [sys].[remote_data_archive_tables];
GO


-------------------------------------------------------------------------------
-- Getting the actual state of data movement and also errors that occur during
-- data movement
-------------------------------------------------------------------------------
SELECT * FROM [sys].[dm_db_rda_migration_status];
GO


-------------------------------------------------------------------------------
-- Resume data migration
-------------------------------------------------------------------------------
ALTER TABLE [Sales].[OrderTracking]
    SET ( REMOTE_DATA_ARCHIVE ( MIGRATION_STATE = OUTBOUND ) ) ;
GO

SELECT * FROM [sys].[remote_data_archive_tables];
SELECT [is_migration_paused] FROM [sys].[remote_data_archive_tables] WHERE [object_id] = OBJECT_ID('Sales.OrderTracking');
GO

