-- =============================================================================
--                              Andre Essing
-- -----------------------------------------------------------------------------
-- Developer.......: Andre Essing (https://github.com/aessing)
--                                (https://twitter.com/aessing)
--                                (https://www.linkedin.com/in/aessing/)
-- -----------------------------------------------------------------------------
-- File.........: DEMO00 - Prepare Environment.sql
-- Summary......: Securing the SQL Server instance
-- Part of......: Talk SQL Server Security
-- Date.........: 25.09.2016
-- Version......: 01.00.00
-- -----------------------------------------------------------------------------
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
-- EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
-- =============================================================================



-- ============================================================================
-- Create a database
-- ============================================================================
CREATE DATABASE [SecureDB]


-- ============================================================================
-- Create login and user
-- ============================================================================
USE [master]
GO
CREATE LOGIN [SecureUser] WITH PASSWORD=N'Pa$$w0rd'
                           , DEFAULT_DATABASE=[master]
						   , DEFAULT_LANGUAGE=[us_english]
						   , CHECK_EXPIRATION=OFF
						   , CHECK_POLICY=OFF;
GO

USE [SecureDB]
GO
CREATE USER [SecureUser] FOR LOGIN [SecureUser] WITH DEFAULT_SCHEMA=[dbo];
GO
ALTER ROLE [db_datareader] ADD MEMBER [SecureUser];
ALTER ROLE [db_datawriter] ADD MEMBER [SecureUser];
GO

