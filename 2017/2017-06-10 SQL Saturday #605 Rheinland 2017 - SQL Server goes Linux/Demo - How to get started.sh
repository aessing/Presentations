#!/bin/bash 

# =============================================================================
#                                Andre Essing
# -----------------------------------------------------------------------------
#
# Developer.......: Andre Essing (https://github.com/aessing)
#                                (https://twitter.com/aessing)
#                                (https://www.linkedin.com/in/aessing/)
#
# -----------------------------------------------------------------------------
#
# Copyright (C) Andre Essing. All rights reserverd.
#
# You may alter this code for your own 'non-commercial' purposes. You may
# republish altered code as long as you include this copyright and give due
# credit.
#
# THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND,
# EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
#
# =============================================================================

# ======================================
# DEMO 1
# ======================================

# Get root
sudo su -

# Import the public repository GPG keys and register the Microsoft SQL Server Ubuntu repositories (Server and Tools)
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server.list | sudo tee /etc/apt/sources.list.d/mssql-server.list
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list

# Update APT repositories
apt-get update

# Install SQL Server
apt-get install -y mssql-server
/opt/mssql/bin/mssql-conf setup
ufw allow 1433/tcp

# Install SQL Server Agent and Full-Text engine
apt-get install -y mssql-server-agent mssql-server-fts
systemctl restart mssql-server

# Install SQL Server Tools
apt-get install -y mssql-tools unixodbc-dev
export PATH=/opt/mssql-tools/bin:$PATH
sqlcmd -Slocalhost -Usa -Q "SELECT name FROM sys.databases;"

# Install Integration Services
apt-get install -y mssql-server-is
/opt/ssis/bin/ssis-conf
export PATH=/opt/ssis/bin:$PATH
gpasswd -a "USER" ssis
dtexec 

# ======================================
# DEMO 1
# ======================================

# Pull image from docker repository
docker pull  microsoft/mssql-server-linux

# Show nothing is running or prepared
docker ps -a

# Create and run docker container with SQL Server on Linux (Connect to it)
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Pa$$w0rd' -p 1433:1433 -d microsoft/mssql-server-linux

# Show the actual running container
docker ps -a