-- =============================================================================
--                              Andre Essing
-- -----------------------------------------------------------------------------
-- Developer.......: Andre Essing (https://github.com/aessing)
--                                (https://twitter.com/aessing)
--                                (https://www.linkedin.com/in/aessing/)
-- -----------------------------------------------------------------------------
-- File.........: DEMO03 - Securing the database.sql
-- Summary......: Securing SQL Server databases
-- Part of......: Talk SQL Server Security
-- Date.........: 25.09.2016
-- Version......: 01.00.00
-- -----------------------------------------------------------------------------
-- THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
-- EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
-- =============================================================================


-- ============================================================================
-- Set some database level security parameters
-- ============================================================================
-- Disable Cross Databases Ownership Chaining ond database level  
ALTER DATABASE SecureDB SET DB_CHAINING OFF;

-- Disable Trutworthy database option
ALTER DATABASE SecureDB SET TRUSTWORTHY OFF;


-- ****************************************************************************
--  Create a database owner
-- ****************************************************************************
USE master;
GO

-- Create login
DECLARE @SQLCMD NVARCHAR(MAX);
SET @SQLCMD = 'CREATE LOGIN [DatabaseOwner] WITH PASSWORD='''
    + SUBSTRING(CONVERT(VARCHAR(255), NEWID()), 0, 32)
    + ''',  SID = 0x48C19BF22476445F980C672EFD1FF204, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF;';
EXEC (@SQLCMD);
 
-- Deny permissions from login
DENY CONNECT SQL TO [DatabaseOwner];
DENY VIEW ANY DATABASE TO [DatabaseOwner];
ALTER LOGIN [DatabaseOwner] DISABLE;

-- Change dbowner to new
USE [SecureDB]
GO
EXEC dbo.sp_changedbowner @loginame = N'DatabaseOwner', @map = false;
GO


-- ============================================================================
-- Convert the database to a partitially contained one
-- ============================================================================
-- Convert database to contained database
USE [master]  
GO

ALTER DATABASE [SecureDB] SET CONTAINMENT = PARTIAL;
GO  

-- Convert logins to database users contained int the database
USE SecureDB;
GO

DECLARE @username sysname ;  
DECLARE user_cursor CURSOR  
    FOR   
        SELECT dp.name   
        FROM sys.database_principals AS dp  
        JOIN sys.server_principals AS sp   
        ON dp.sid = sp.sid  
        WHERE dp.authentication_type = 1 AND sp.is_disabled = 0;  
OPEN user_cursor  
FETCH NEXT FROM user_cursor INTO @username  
    WHILE @@FETCH_STATUS = 0  
    BEGIN  
        EXECUTE sp_migrate_user_to_contained   
        @username = @username,  
        @rename = N'keep_name',  
        @disablelogin = N'disable_login';  
    FETCH NEXT FROM user_cursor INTO @username  
    END  
CLOSE user_cursor ;  
DEALLOCATE user_cursor ;
GO


-- ============================================================================
-- Encrypt databases with Transparent Data Encryption (TDE)
-- ============================================================================
-- Create the masker key for the instance (in master database) 
USE [master];
GO
 
CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'8enw8Vv&EmCGbcks3kB7/2on&ZvnYsbDcKDyc=ZYAYQQZn)TYy';
GO

BACKUP MASTER KEY TO FILE = N'C:\DEMO001\BCKP01\MSSQL\MK_SQLSECURITY_DEMO001.key' 
	ENCRYPTION BY PASSWORD = N'^fbVExEWvJryxDsdRbjE]oQ2$dEQkMAuF68yU6F7{nYx]iGFVg'
GO

-- Create a certificate in the master database to encrypt a database
CREATE CERTIFICATE [CERT_TDE_SecureDB] WITH SUBJECT = N'Certificate TDE SecureDB';
GO

BACKUP CERTIFICATE [CERT_TDE_SecureDB]
	TO FILE = N'C:\DEMO001\BCKP01\MSSQL\CERT_TDE_SecureDB.cert'
	WITH PRIVATE KEY (FILE = N'C:\DEMO001\BCKP01\MSSQL\CERT_TDE_SecureDB.key',
	ENCRYPTION BY PASSWORD = N'RKgRkTiEukW7QrWiavB6;{{KwNYDo)korujsf3bDWADje4J}2P');
GO

-- Now, encrypt the database itself
USE SecureDB;
GO

CREATE DATABASE ENCRYPTION KEY
	WITH ALGORITHM = AES_256
	ENCRYPTION BY SERVER CERTIFICATE [CERT_TDE_SecureDB];
GO

ALTER DATABASE SecureDB SET ENCRYPTION ON;
GO

-- Check encryption state
SELECT DB_NAME([database_id]) AS [DatabaseName], * FROM [sys].[dm_database_encryption_keys]; 
GO
