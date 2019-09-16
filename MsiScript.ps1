$MsiListToInstall = @(
### List your MSI packages here ###
)
  
### Set your database and credentials for database ###
$DBName = "TPCentralDB"
$DBLogin = "sa"
$DBPassword = "--PasswordForDatabase--"
  
############################################################################################################
  
Clear
  
$ConnectionString = "Data Source=localhost;database=$($DBName);User ID=$($DBLogin);Password=$($DBPassword);"
$sqlConn = new-object ("Data.SqlClient.SqlConnection") $ConnectionString
  
$ERROR_SUCCESS_REBOOT_REQUIRED = 3010
  
try
{
    $sqlConn.Open();
}
catch
{
    Write-Host "Database TPCentralDB is " -NoNewLine
    Write-Host " UNAVAILABLE " -ForeGround White -BackGround Red
    Write-Host "`nInstallation is aborted"
      
    $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
      
    exit
}
  
$sqlConn.Close();
$ErrorCount = 0
  
$StartTime = Get-Date
$FullPathToCurrentDir = Convert-Path .
  
foreach ($CurrentMsi in $MsiListToInstall) {
      
    Write-Host "$($CurrentMsi) " -NoNewLine
      
    if (-not (Test-Path "$($FullPathToCurrentDir)\$($CurrentMsi)"))
    {
        Write-Host "is missing `n" -ForeGround DarkGray
        continue
    }
      
    $DataStamp = get-date -Format yyyyMMddTHHmmss
    $logFile = '{0}-{1}.log' -f $CurrentMsi,$DataStamp
    $MSIArguments = @(
        "/i"
        ('"{0}"' -f $CurrentMsi)
        "/qn"
        "SUPPRESS_REBOOT=Y"
        "/L*v"
        $logFile
    )
  
    #Write-Output "Log file: $logFile"
  
    $ProcResult = Start-Process "msiexec.exe" -ArgumentList $MSIArguments -Wait -NoNewWindow -PassThru
 
    if (($ProcResult.ExitCode -ne 0) -and ($ProcResult.ExitCode -ne $ERROR_SUCCESS_REBOOT_REQUIRED)) {
        $ErrorCount = $ErrorCount + 1
        Write-Host " ERROR `n" -ForeGround White -BackGround Red
        Write-Host "Installation process returned error code: $($ProcResult.ExitCode)"
        break
    }
    else {
        #Write-Host "The ExitCode is $($ProcResult.ExitCode). $($CurrentMsi) is installed with SUCCESS `n" -ForeGround Black -BackGround Green
        Write-Host " SUCCESS " -ForeGround Black -BackGround Green -NoNewLine
        Write-Host " ExitCode: $($ProcResult.ExitCode) `n"
    }
 
 
    Start-Sleep -Seconds 5
}
  
$EndTime = Get-Date
$Duration = $EndTime - $StartTime
  
if ($ErrorCount -ne 0) {
Write-Host "`nInstallation is completed " -NoNewLine
Write-Host " with ERRORS " -ForeGround White -BackGround Red -NoNewLine
Write-Host " in $([int]$Duration.TotalMinutes) minutes"
}
else {
Write-Host "`n Installation is completed " -ForeGround Black -BackGround Green -NoNewLine
Write-Host " in $([int]$Duration.TotalMinutes) minutes"
}
  
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
