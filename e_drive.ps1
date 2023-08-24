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

# Robocopy log file variables
$PathRobocopyLogs    = "C:\Robolog"
$NameRobocopyLog     = "robolog.log"
$RobocopyLogFile     = $PathRobocopyLogs + '\' + $NameRobocopyLog 

# -------------------------------------
# Connect to Azure
# -------------------------------------
#Connect-AzAccount -Tenant $TenantId -SubscriptionId $SubscriptionId -devicecode
#Select-AzSubscription -SubscriptionId $SubscriptionId

# -------------------------------------
# Map Azure Files
# -------------------------------------

# Share constructor
$AzureUser            = "/user:Azure\"+$StorageAccountName
$StorageKeys          = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -AccountName $StorageAccountName
$StorageKey           = $StorageKeys[0].value
net use $letterAzure /d
net use $letterAzure $uncPathAzure $AzureUser $StorageKey


# -------------------------------------
# Create robocopy directories
# -------------------------------------
if (Test-Path -Path $PathRobocopyLogs) {
    Write-Host "Path $PathRobocopyLogs already exists ... it will be used" -ForegroundColor yellow
} else {
    Write-Host "Path $PathRobocopyLogs doesn't exist... creating it"  -ForegroundColor green
    New-Item -Path $PathRobocopyLogs -ItemType "directory"
    Write-Host "Path $PathRobocopyLogs was created"  -ForegroundColor green
}

# -------------------------------------
# Robocopy process
# -------------------------------------
Write-host
$RetainLogsResponse = Read-Host "Do you want to log activity for this robocopy execution? y/n"

if ($RetainLogsResponse='y') {
    # Without logs (performance):
    robocopy $SourcePathOnPremises $letterAzure /E /COPY:DATS /DCOPY:DAT /MIR /R:1 /W:1 /MT:128 /NP /NFL /NDL
}
else{

    # With logs (logging):
    robocopy $SourcePathOnPremises $letterAzure /E /COPY:DATS /DCOPY:DAT /MIR /R:1 /W:1 /MT:128 /V /LOG+:$RobocopyLogFile
}
