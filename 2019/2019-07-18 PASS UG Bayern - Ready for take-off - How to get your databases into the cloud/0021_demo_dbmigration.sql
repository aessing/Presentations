/*============================================================================
                             Andre Essing
-----------------------------------------------------------------------------
Developer.......: Andre Essing (https://github.com/aessing)
                               (https://twitter.com/aessing)
                               (https://www.linkedin.com/in/aessing/)
-----------------------------------------------------------------------------
	File:		0021_demo_dbmigration.sql

	Summary:    This script does the has a look at the SQL DB migration

				THIS SCRIPT IS PART OF THE TRACK: Ready for take-off
				                                  How to get your databases
												  into the cloud"

	Date:		June 2019

	SQL Server Version: 2008 / 2012 / 2014 / 2016 / 2017
------------------------------------------------------------------------------
	Written by Andre Essing, Microsoft Deutschland GmbH

	This script is intended only as a supplement to demos and lectures
	given by Andre Essing.  
  
	THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
	ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
	TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
	PARTICULAR PURPOSE.
============================================================================*/

SELECT * FROM [Northwind].[dbo].[Categories]

INSERT INTO [dbo].[Categories] ([CategoryName],[Description])
VALUES ('SQLDEMO', 'An awesome demo')

SELECT * FROM [Northwind].[dbo].[Categories]

DELETE FROM  [dbo].[Categories]
WHERE [CategoryName] = 'SQLDEMO'

SELECT * FROM [Northwind].[dbo].[Categories]


-- ============================================================================
-- EOF