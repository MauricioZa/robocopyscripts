# -------------------------------------
# Variables
# -------------------------------------

# Azure Subscription details
$StorageAccountName   = "pbspszqarzcp001"

# Azure file share info
$letterAzure          = "z:"
$uncPathAzure         = "\\pbspszqarzcp001.file.core.windows.net\work"

# OnPremises share info
$SourcePathOnPremises = "E:\DATA\WORK"
$ExcludeFolders = 'a borrar' 'a migrar'

# Robocopy log file variables
$PathRobocopyLogs    = "C:\Robolog"
$NameRobocopyLog     = "robolog_E.log"
$RobocopyLogFile     = $PathRobocopyLogs + '\' + $NameRobocopyLog 


# -------------------------------------
# Map Azure Files
# -------------------------------------

# Share constructor
$AzureUser            = "/user:Azure\"+$StorageAccountName
$StorageKey           = '<insert key>'
net use $letterAzure /d
net use $letterAzure $uncPathAzure $AzureUser $StorageKey


# -------------------------------------
# Create robocopy directories
# -------------------------------------
if (Test-Path -Path $PathRobocopyLogs) {
    Write-Host "Path $PathRobocopyLogs already exists ... it will be used" -ForegroundColor yellow
} 
else {
    Write-Host "Path $PathRobocopyLogs doesn't exist... creating it"  -ForegroundColor green
    New-Item -Path $PathRobocopyLogs -ItemType "directory"
    Write-Host "Path $PathRobocopyLogs was created"  -ForegroundColor green
}

# -------------------------------------
# Robocopy process
# -------------------------------------
Write-host '----------------------------------------------------------------------------------------'
$RetainLogsResponse = Read-Host "Do you want to log activity for this robocopy execution? y/n"
Write-host '----------------------------------------------------------------------------------------'

if ($RetainLogsResponse -eq 'n') {
    # Without logs (performance):
    Write-host 
    Write-host 'Logs are NOT going to be saved' -Foregroundcolor green
    Write-host 'SOURCE        :'$SourcePathOnPremises -Foregroundcolor green
    Write-host 'DESTINATION   :'$uncPathAzure -Foregroundcolor green
    Write-Host
    $Continue = Read-Host "Press enter to continue. Or C to cancel" 
    If ($Continue -eq 'c' -or $Continue -eq 'C') {
        exit
    }
    Else {
        robocopy $SourcePathOnPremises $letterAzure /E /COPY:DATS /DCOPY:DAT /MIR /R:1 /W:1 /MT:128 /NP /NFL /NDL /XD "a borrar" "a migrar"
    }
    
}
elseif ($RetainLogsResponse -eq 'y') {

    # With logs (logging):
    Write-host 
    Write-host 'Logs will be saved to' $RobocopyLogFile -Foregroundcolor green
    Write-host 'SOURCE        :'$SourcePathOnPremises -Foregroundcolor green
    Write-host 'DESTINATION   :'$uncPathAzure -Foregroundcolor green
    Write-Host
    Read-Host "Press enter to continue. C to cancel" 
    If ($Continue -eq 'c' -or $Continue -eq 'C') {
        exit
    }
    Else {
        robocopy $SourcePathOnPremises $letterAzure /E /COPY:DATS /DCOPY:DAT /MIR /R:1 /W:1 /MT:128 /V /XD "a borrar" "a migrar" /LOG:$RobocopyLogFile
    }
    
}
