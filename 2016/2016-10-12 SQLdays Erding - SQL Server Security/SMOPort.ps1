# Script to Set Static TCP port number for a SQL Server Instance
# Created by - Vinoth N Manoharan
# Version 1.0
# Date - 16/05/2013
# Script Help :-
#---------------
# Parameter 1 :- "-s" to specify the SQL Server Name
# Parameter 2 :- "-p" to TCP Port Number to be Set
# Example1:- SMOPort.ps1 -s SQLServerName-p tcpport
# Example2:- SMOPort.ps1 -s MyTestServer -p 1433
# Example3:- SMOPort.ps1 -s MyTestServer\Instance1 -p 1433
 
#Reference http://sqlblog.com/blogs/allen_white/default.aspx
 
Clear-Host
function IsNumeric { 
  
<#Reference http://gallery.technet.microsoft.com/scriptcenter/IsNumeric-c50ecf05    
.SYNOPSIS    
    Analyse whether input value is numeric or not 
    
.DESCRIPTION    
    Allows the administrator or programmer to analyse if the value is numeric value or  
    not. 
      
    By default, the return result value will be in 1 or 0. The binary of 1 means on and  
    0 means off is used as a straightforward implementation in electronic circuitry  
    using logic gates. Therefore, I have kept it this way. But this IsNumeric cmdlet  
    will return True or False boolean when user specified to return in boolean value  
    using the -Boolean parameter. 
  
.PARAMETER Value 
      
    Specify a value 
  
.PARAMETER Boolean 
      
    Specify to return result value using True or False 
  
.EXAMPLE 
    Get-ChildItem C:\Windows\Logs | where { $_.GetType().Name -eq "FileInfo" } | Select -ExpandProperty Name | IsNumeric -Verbose
    DirectX.log 
    VERBOSE: False 
    0 
    IE9_NR_Setup.log 
    VERBOSE: False 
    0 
  
    The default return value is 0 when we attempt to get the files name through the  
    pipeline. You can see the Verbose output stating False when you specified the  
    -Verbose parameter 
  
.EXAMPLE 
    Get-ChildItem C:\Windows\Logs | where { $_.GetType().Name -eq "FileInfo" } | Select -ExpandProperty Length | IsNumeric -Verbose
    119155 
    VERBOSE: True 
    1 
    2740 
    VERBOSE: True 
    1 
      
    The default return value is 1 when we attempt to get the files length through the  
    pipeline. You can see the Verbose output stating False when you specified the  
    -Verbose parameter 
          
.EXAMPLE 
    $IsThisNumbers? = ("1234567890" | IsNumeric -Boolean) ; $IsThisNumbers? 
    True 
      
    The return value is True for the input value 1234567890 because we specified the  
    -Boolean parameter 
      
.EXAMPLE     
    $IsThisNumbers? = ("ABCDEFGHIJ" | IsNumeric -Boolean) ; $IsThisNumbers? 
    False 
  
    The return value is False for the input value ABCDEFGHIJ because we specified the  
    -Boolean parameter 
  
.NOTES    
    Author  : Ryen Kia Zhi Tang 
    Date    : 20/07/2012 
    Blog    : ryentang.wordpress.com 
    Version : 1.0 
      
#> 
  
[CmdletBinding( 
    SupportsShouldProcess=$True, 
    ConfirmImpact='High')] 
  
param ( 
  
[Parameter( 
    Mandatory=$True, 
    ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True)] 
      
    $Value, 
      
[Parameter( 
    Mandatory=$False, 
    ValueFromPipeline=$True, 
    ValueFromPipelineByPropertyName=$True)] 
    [alias('B')] 
    [Switch] $Boolean
      
) 
      
BEGIN { 
  
    #clear variable 
    $IsNumeric = 0 
  
} 
  
PROCESS { 
  
    #verify input value is numeric data type 
    try { 0 + $Value | Out-Null
    $IsNumeric = 1 }catch{ $IsNumeric = 0 } 
  
    if($IsNumeric){  
        $IsNumeric = 1 
        if($Boolean) { $Isnumeric = $True } 
    }else{  
        $IsNumeric = 0 
        if($Boolean) { $IsNumeric = $False } 
    } 
      
    if($PSBoundParameters['Verbose'] -and $IsNumeric) {  
    Write-Verbose "True" }else{ Write-Verbose "False" } 
      
     
    return $IsNumeric
} 
  
END {} 
  
} #end of #function IsNumeric
 
 
 
 
 
<#*************************************************START:Main Program***************************************************************#>
<#Command Line Argument Verification#>
if($args.Length -ne 4)
{
Write-Host "Incorrect Paramenter Count use -c to specify the User Input File and use -a to specify the Action" -ForegroundColor Red
$uParameterHelp = "
Help:-
******
 # Parameter 1 :- '-s' to specify the SQL Server Name
 # Parameter 2 :- '-p' to TCP Port Number to be Set
 # Example1:- SMOPort.ps1 -s SQLServerName-p tcpport
 # Example2:- SMOPort.ps1 -s MyTestServer -p 1433
 # Example3:- SMOPort.ps1 -s MyTestServer\Instance1 -p 1433"
Write-Host $uParameterHelp -ForegroundColor Yellow
}
<#START:Install MAIN Program#>
elseif((($args[0] -eq "-s") -or ($args[0] -eq "-S")) -and (($args[2] -eq "-p") -or ($args[2] -eq "-P")))
{
$computer = $args[1]
$Error = 0
#Get the SQL and Instance name
$SQLInstance = $computer.Split("\")
$SQlcompname = $SQLInstance[0]
 if($SQLInstance[1] -eq $null)
 {
  $instname = "MSSQLSERVER"
  $SQLServicename = "MSSQLSERVER"
  $AgentServiceName = "SQLSERVERAGENT"
 }else
  {$instname = $SQLInstance[1];
   $SQLServicename = "MSSQL$"+$instname
   $AgentServiceName = "SQLAgent$"+$instname
  }
 
$portnumber = $args[3]
#Check if Port number passed is Numeric 
 if (($portnumber | IsNumeric -Boolean))
 {
   Try
   {
   # Load the assemblies
   [system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")|Out-Null
   [system.reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")|Out-Null
   $mc = new-object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer $SQlcompname
   $i=$mc.ServerInstances[$instname]
   $p=$i.ServerProtocols['Tcp']
   $ip=$p.IPAddresses['IPAll']
   $ip.IPAddressProperties['TcpDynamicPorts'].Value = ''
   $ipa=$ip.IPAddressProperties['TcpPort']
   $ipa.Value = [string]$portnumber
   $p.Alter()
   #$ip.IPAddressProperties['TcpDynamicPorts'].Value = '1099'
   #$p.Alter()
   }
   Catch
   {
    Write-host -ForegroundColor Red "ERROR[Assign IP]:"$_.Exception.Message
    $Error = 1
   }
   Finally
   {
     if($Error -eq 1)
     {
      Write-host -ForegroundColor Red "ERROR[Assign IP]:FAILED!!!!"
      EXIT;
     }
     else
     {
      Write-host -ForegroundColor Green "[Assign IP]:SUCCESS-SQL Server TCP Port reconfigured to $portnumber, Restart the SQL Services for the Prot to be reconfigured!!!"
     }
   }
 }
 Else
 {
  Write-Host "ERROR : Incorrect Port Number, Port number for argument '-p' should be Numeric!" -ForegroundColor Red
  $uParameterHelp = "
Help:-
******
 # Parameter 1 :- '-s' to specify the SQL Server Name
 # Parameter 2 :- '-p' to TCP Port Number to be Set
 # Example1:- SMOPort.ps1 -s SQLServerName-p tcpport
 # Example2:- SMOPort.ps1 -s MyTestServer -p 1433
 # Example3:- SMOPort.ps1 -s MyTestServer\Instance1 -p 1433"
 Write-Host $uParameterHelp -ForegroundColor Yellow
 }
}
