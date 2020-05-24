/*============================================================================
###############################################################################
                             Andre Essing
-----------------------------------------------------------------------------
Developer.......: Andre Essing (https://github.com/aessing)
                               (https://twitter.com/aessing)
                               (https://www.linkedin.com/in/aessing/)
-----------------------------------------------------------------------------
	File:		0031_demo_mimigration.sql

	Summary:    This script does the backups to demonstrate SQL Managed
                Instance online migration

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

-- ----------------------------------------------------------------------------
-- CREATE INITIAL DATABASE BACKUP
-- ----------------------------------------------------------------------------
BACKUP DATABASE [AdventureWorks2017]
TO DISK = 'F:\Migration\AdventureWorks2017-FULL.bak'
WITH CHECKSUM;


-- ----------------------------------------------------------------------------
-- CREATE TRANSACTION LOG BACKUP
-- ----------------------------------------------------------------------------
BACKUP Log [AdventureWorks2017]
TO DISK = 'F:\Migration\AdventureWorks2017-TLOG-01.trn'
WITH CHECKSUM;

BACKUP Log [AdventureWorks2017]
TO DISK = 'F:\Migration\AdventureWorks2017-TLOG-02.trn'
WITH CHECKSUM;

BACKUP Log [AdventureWorks2017]
TO DISK = 'F:\Migration\AdventureWorks2017-TLOG-03.trn'
WITH CHECKSUM;


-- ----------------------------------------------------------------------------
-- CREATE TAILLOG BACKUP
-- ----------------------------------------------------------------------------
BACKUP Log [AdventureWorks2017]
TO DISK = 'F:\Migration\AdventureWorks2017-TLOG-Tail.trn'
WITH CHECKSUM;


-- ============================================================================
-- EOF