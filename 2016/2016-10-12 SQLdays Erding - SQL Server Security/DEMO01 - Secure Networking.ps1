# =============================================================================
# Developer.......: Andre Essing (https://github.com/aessing)
#                                (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
# -----------------------------------------------------------------------------
# Developer....: Andre Essing (andre@essing.org)
# -----------------------------------------------------------------------------
# File.........: DEMO01 - Secure Networking.ps1
# Summary......: Securing the SQL Server instance
# Part of......: Talk SQL Server Security
# Date.........: 25.09.2016
# Version......: 01.00.00
# -----------------------------------------------------------------------------
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
# =============================================================================


$sqlInstance = "MSSQL13.DEMO001"
$dnsName = "SQLSecurity"


# -----------------------------------------------------------------------------
# Tell Browser to hide SQL Server instance
# -----------------------------------------------------------------------------
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlInstance\MSSQLServer\SuperSocketNetLib" -name "HideInstance" -value 1 -force -Type DWORD


# -----------------------------------------------------------------------------
# Disable browser service completely
# -----------------------------------------------------------------------------
Set-Service -Name SQLBrowser -StartupType Disabled -Status Stopped


# -----------------------------------------------------------------------------
# Disable unused network protocolls (NETBIOS, VIA)
# -----------------------------------------------------------------------------
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlInstance\MSSQLServer\SuperSocketNetLib\Np" -name "Enabled" -value 0 -force -Type DWORD
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlInstance\MSSQLServer\SuperSocketNetLib\Via" -name "Enabled" -value 0 -force -Type DWORD


# -----------------------------------------------------------------------------
# Change SQL Server TCP/IP Port
# -----------------------------------------------------------------------------
.\SMOPort.ps1 -s "SQLSECURITY\DEMO001" -p 50443


# -----------------------------------------------------------------------------
# Check if SQL Server encrypts the connections
# -----------------------------------------------------------------------------
Invoke-Sqlcmd -ServerInstance "SQLSecurity\DEMO001" -Query "SELECT encrypt_option FROM sys.dm_exec_connections WHERE session_id = @@SPID"


# -----------------------------------------------------------------------------
# Create a self signed certificate (self signed for demo only)
# -----------------------------------------------------------------------------
New-SelfSignedCertificate -certstorelocation cert:\localmachine\my -DnsName $dnsName


# -----------------------------------------------------------------------------
# Permit SQL Server to access certificate
# Some manual work, because certificate storage provider in W2012 isn't working
# Account: svcSQLDB
# -----------------------------------------------------------------------------
certlm.msc


# -----------------------------------------------------------------------------
# Assign certificate to SQL Server instance
# -----------------------------------------------------------------------------
$sqlCert = Get-ChildItem -Recurse Cert:\LocalMachine\My -DnsName $dnsName
$certThumbprint = $sqlCert.Thumbprint
$certThumbprint = $certThumbprint -replace '\s',''
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlInstance\MSSQLServer\SuperSocketNetLib" -name "Certificate" -value $certThumbprint -force -Type String


# -----------------------------------------------------------------------------
# Tell SQL Server to force network encryption
# -----------------------------------------------------------------------------
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$sqlInstance\MSSQLServer\SuperSocketNetLib" -name "ForceEncryption" -value 1 -force -Type DWORD


# -----------------------------------------------------------------------------
# Restart SQL Server Service
# -----------------------------------------------------------------------------
Restart-Service -Name 'MSSQL$DEMO001' -Force


# -----------------------------------------------------------------------------
# Check if SQL Server encrypts the connections
# -----------------------------------------------------------------------------
Invoke-Sqlcmd -ServerInstance "SQLSecurity\DEMO001" -Query "SELECT encrypt_option FROM sys.dm_exec_connections WHERE session_id = @@SPID"
