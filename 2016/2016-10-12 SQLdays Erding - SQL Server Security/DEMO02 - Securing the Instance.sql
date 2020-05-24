-- =============================================================================
--                              Andre Essing
-- -----------------------------------------------------------------------------
-- Developer.......: Andre Essing (https://github.com/aessing)
--                                (https://twitter.com/aessing)
--                                (https://www.linkedin.com/in/aessing/)
-- -----------------------------------------------------------------------------
-- File.........: DEMO01 - Securing the instance.sql
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
-- Disable SQL Server Logins, allow only Windows Authentication
-- ============================================================================
EXEC [xp_instance_regwrite] N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer', N'LoginMode', [REG_DWORD], 1;
GO


-- ============================================================================
-- Configure some instance level security options
-- ============================================================================
EXEC [sys].[sp_configure] N'show advanced options', N'1';
RECONFIGURE WITH OVERRIDE;
GO

-- Restrict access to remote data sources with OPENROWSET- and OPENDATASOURCE
EXEC [sys].[sp_configure] N'Ad Hoc Distributed Queries', N'0';

-- Do not allow updates to system tables (Deprecated, has no effect since SQL Server 2005)
EXEC [sys].[sp_configure] N'allow updates', N'0';

-- Do not allow .NET assemblies to run in SQL Server / If necessary, allow only safe assemblies
EXEC [sys].[sp_configure] N'clr enabled', N'0';

-- Deny running OLE automation objects in SQL Server
EXEC [sys].[sp_configure] N'Ole Automation Procedures', N'0';

-- Do not allow chaining of object ownership across databases
EXEC [sys].[sp_configure] N'cross db ownership chaining', N'0';

-- Disables access to DAC from remote computers
EXEC [sys].[sp_configure] N'remote admin connections', N'0';

-- Do not allow procedures to run at SQL Server startup
EXEC [sys].[sp_configure] N'scan for startup procs', N'0';

-- Don not allow to run  XP_CMDSHELL procedure
EXEC [sys].[sp_configure] N'xp_cmdshell', N'0';

-- Allow to create contained databases
EXEC [sys].[sp_configure] N'contained database authentication', N'1';

RECONFIGURE WITH OVERRIDE;
GO

EXEC [sys].[sp_configure] N'show advanced options', N'0';
RECONFIGURE WITH OVERRIDE;
GO


-- ============================================================================
-- Rename SA
-- ============================================================================
ALTER LOGIN [sa] WITH NAME = [DarthVader];
GO
DENY CONNECT SQL TO [DarthVader]
ALTER LOGIN [DarthVader] DISABLE
GO
