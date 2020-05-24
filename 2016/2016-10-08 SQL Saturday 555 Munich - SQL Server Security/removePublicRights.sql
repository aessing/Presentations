/****************************************************************************************************************
** FILE NAME: [Remove public and guest permissions.sql]
** http://blogs.technet.com/b/fort_sql/archive/2010/02/04/remove-public-and-guest-permissions.aspx
****************************************************************************************************************
** PURPOSE: Remove public and guest permissions
****************************************************************************************************************
** VERSION HISTORY:
** 30Sep2009, John Lambert, Microsoft SQL Server Premier Field Engineer: Created script.
** 04Feb2010, John Lambert: Corrected revoke-guest/connect to skip master & tempdb and execute only once per db.
** 09Sep2010, Rick Davis, Microsoft Senior Consultant: Enhanced script to work with any legally named object and
**			  added a script only mode.
****************************************************************************************************************
** COMPATIBILITY: The code below is compatible with SS05, SS08, and SSR2.
****************************************************************************************************************
** STEPS:
** 1. Run the script to generate a list of the permissions that will be changed.
** 2. Save the list for future reference.
** 3. Change the execution mode by uncommenting: set @modeScriptOnly = 0;
** 4. Run the script to reduce the permissions.
****************************************************************************************************************
** BACKGROUND INFORMATION:
**
** Make SQL Server 2005 compliant with the DoD STIG/SRR, Requirement DM6196 and DM1709.
** This script:
**    Revokes the VIEW ANY DATABASE permission from the master database
**    Revokes all object privileges assigned to public or guest for every database
**    Revokes the connect permission from guest on all databases except master and tempdb
****************************************************************************************************************
****************************************************************************************************************/

DECLARE @modeScriptOnly bit;
set @modeScriptOnly = 1;	-- script commands to be executed later
--set @modeScriptOnly = 0;	-- execute generated commands

USE master;

IF @modeScriptOnly = 1
	PRINT 'REVOKE VIEW ANY DATABASE FROM PUBLIC;';
ELSE
	REVOKE VIEW ANY DATABASE FROM PUBLIC;

DECLARE @database	varchar(100)
	,	@permission varchar(100)
	,	@schema		varchar(100)
	,	@sql		nvarchar(1000)
	,	@object		varchar(100)
	,	@role		varchar(100);

DECLARE csrDatabases CURSOR FAST_FORWARD FOR 
	SELECT name FROM sys.databases ORDER BY name;
	
OPEN csrDatabases;
FETCH NEXT FROM csrDatabases INTO @database;

WHILE (@@fetch_status = 0)
BEGIN
	SET @sql = 
		'DECLARE csrObjects CURSOR FAST_FORWARD FOR 
		SELECT p.permission_name, [schema] = SCHEMA_NAME(o.schema_id), object_name = o.name, role_name = u.name
		FROM [' + @database + '].sys.database_permissions p
		INNER JOIN [' + @database + '].sys.database_principals u ON p.grantee_principal_id = u.principal_id
		INNER JOIN [' + @database + '].sys.all_objects o ON o.object_id = p.major_id
		WHERE p.grantee_principal_id IN (0, 2) 
		ORDER BY u.name, o.schema_id, o.name, p.permission_name;';
	EXECUTE sp_executesql @sql;
	
	OPEN csrObjects;
	FETCH NEXT FROM csrObjects INTO @permission, @schema, @object, @role;
	
	WHILE (@@fetch_status = 0)
	BEGIN
		SELECT @sql = 'USE [' + @database + ']; REVOKE ' + @permission + ' ON [' + @schema + '].[' + @object + '] FROM ' + @role + ';';
		IF @modeScriptOnly = 1
			PRINT @sql;
		ELSE
			EXEC sp_executesql @sql;

		FETCH NEXT FROM csrObjects INTO @permission, @schema, @object, @role;
	END
	
	IF @database NOT IN ('master', 'tempdb')
	BEGIN
		SELECT @sql = 'USE [' + @database + ']; REVOKE CONNECT FROM GUEST;';
		IF @modeScriptOnly = 1
			PRINT @sql;
		ELSE
			EXEC sp_executesql @sql;
	END
	
	CLOSE csrObjects;
	DEALLOCATE csrObjects;

	FETCH NEXT FROM csrDatabases INTO @database;
END
CLOSE csrDatabases;
DEALLOCATE csrDatabases;