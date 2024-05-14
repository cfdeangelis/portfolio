#Installation Prerequisites_Before Restart Script
#Created on 03-MAY-2024
#Created by Christopher DeAngelis

#########################################################################################################################################################
#Global Variables
$ServerName = $env:COMPUTERNAME
$VerificationPath = "D:\"+$ServerName+"_InstallationPrerequisiteVerifications"
$NewLines = "`n" * 5


#Global Functions
function Yellow {
    $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Yellow
}

function White {
    $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::White
}

function AppendServerName {
    "SERVER: $ServerName`n" | Out-File -FilePath "$VerificationPath\$LOG" -Append
}

function StopNotepad {
    Get-Process -Name "notepad" -ErrorAction SilentlyContinue | Stop-Process -Force 
}

function MonitorFile {
    White
    Write-Host "Monitoring file.  Please close the file to continue."
    $fileToMonitor = "$VerificationPath\$LOG"

    # Check if the file exists
    if (-not (Test-Path $fileToMonitor)) {
        Write-Host "File does not exist: $fileToMonitor"
        exit
    }

    # Wait until the file is closed in notepad.exe
    while ($true) {
        $notepadProcess = Get-Process | Where-Object {$_.ProcessName -eq "notepad"} 
        if (-not $notepadProcess) {
            Write-Host "File is closed"
            break
        }
        Start-Sleep -Seconds 1
    }
}


#Log Verification Functions

function ReviewLog {
    Yellow
    Write-Output $NewLines
    Write-Output $Dashes
    Write-Output $MESSAGE
    Write-Output $Dashes
    White
    PAUSE
    StopNotepad
    notepad.exe $VerificationPath\$LOG
    MonitorFile
    Write-Output $NewLines
}

function 1OrganizationalUnit {
    $LOG = "gpresult.log"
    $MESSAGE = "Press ENTER and check that OU=PMX MFG Servers is present."
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    White
    AppendServerName
    ########log creation########
    gpresult /v | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 2PowershellVersion {
    $LOG = "powershellversion.log"
    $MESSAGE = "Press ENTER and check PowerShell version"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    $psversiontable.PSVersion | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 3.NETFrameworkForMatrikon {
    $LOG = "NETFrameworkVersion.log"
    $MESSAGE = "This step is ONLY for App Servers where Matrikon OPC Tunneler is going to be installed`nIf file is empty and server requires this, raise a request to Windows team`nPress ENTER and check .NET Major and minor version & ServicePack"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    "Major and Minor Version:`n" | Out-File -FilePath "$VerificationPath\$LOG" -Append
    reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5" /v Version | Out-File -FilePath "$VerificationPath\$LOG" -Append
    "ServicePack Version:`n" | Out-File -FilePath "$VerificationPath\$LOG" -Append
    reg query “HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5” /v SP | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 4InstallRDSH {
    $LOG = "EnableRemoteDesktopSessionHostRole.log"
    $MESSAGE = "Press ENTER and check line output for proper Remote Desktop Session Host role service installation"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    Write-Output "change user /install >>" | Out-File -FilePath "$VerificationPath\$LOG" -Append
    & cmd.exe /c "change user /install" | Out-File -FilePath "$VerificationPath\$LOG" -Append
    Write-Output "`nchange user /execute >>" | Out-File -FilePath "$VerificationPath\$LOG" -Append
    & cmd.exe /c "change user /execute" | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 5EnableAdminApprovalMode {
    $LOG = "EnableAdminApprovalModePolicy.log"
    $MESSAGE = "Press ENTER and ensure FilterAdministratorToken has a value of 1 (This means that Admin Approval Mode policy is enabled)"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name FilterAdministratorToken | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 6Enable8.3FileNameCreation {
    $LOG = "Enable8_3FileNameCreation.log"
    $MESSAGE = "Press ENTER and check 8.3 File Creation in enabled (Value should be 0)"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    fsutil.exe behavior query disable8dot3 | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 7DisableWindowsDFSS {
    $LOG = "DisableWindowsDFSS.log"
    $MESSAGE = "Press ENTER and verify that EnableDFSS and EnableDiskFSS entry have a value of 0, and EnableNetworkFSS entry has a value of empty"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    (gwmi win32_terminalservicesetting -N “root\cimv2\terminalservices”) | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

function 8DNSSuffixCompletionPolicy {
    #!!!NOTE: If Yes is entered, this script will update the registry value associated with enabling the DNS Suffix Completion Policy and Enable it, but the policy will remain as "Not configured" in gpedit.msc!!!
    $LOG = "DNSSuffixCompletionPolicy.log"
    $MESSAGE = "Press ENTER and check if DNS Suffix Completion Policy has been enabled (AppendToMultiLabelName: 1) or left unconfigured (AppendToMultiLabelName: 0)"
    $length = $MESSAGE.Length
    $Dashes = "-" * $length

    AppendServerName
    ########log creation########
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name AppendToMultiLabelName | Out-File -FilePath "$VerificationPath\$LOG" -Append
    ########log creation########
    ReviewLog
}

#########################################################################################################################################################


#BEGINNING OF SCRIPT
White
Write-Output "`n`n"
#Warning about Notepad.exe closure
Write-Host "!!WARNING!!: This script will close any open Notepad.exe instances while running.  Ensure your work is saved!" -ForegroundColor Red
PAUSE

# Check if the directory $VerificationPath exists, remove it if it does
if (Test-Path -Path $VerificationPath -PathType Container) {
    Remove-Item -Path $VerificationPath -Recurse -Force
}
# Create the directory $VerificationPath
White
New-Item -Path $VerificationPath -ItemType Directory -Force

$MESSAGE = "Log Path Created at $VerificationPath"
$length = $MESSAGE.Length
$Dashes = "-" * $length
Write-Output $NewLines
Write-Host $Dashes -ForegroundColor Green
Write-Host $MESSAGE -ForegroundColor Green
Write-Host $Dashes -ForegroundColor Green

#Trigger CTX, APP, GW prompt
function Get-ServerTypeInput {
    while ($true) {
        Yellow
        $input = Read-Host "Is this a Citrix, App, or Gateway server? (Type 'CTX', 'APP', or 'GW')"
        if ($input -eq "CTX" -or $input -eq "APP" -or $input -eq "GW") {
            $verify = Read-Host "You entered '$input'. Is this correct? (YES/NO)"
            if ($verify -eq "YES") {
                return $input
            }
        } else {
            Write-Host "Invalid input. Please enter 'CTX', 'APP', or 'GW'."
        }
    }
}
White
# Get user input for server type
$serverType = Get-ServerTypeInput
Write-Output $NewLines

# Run appropriate scripts based on server type
switch ($serverType) {
    "CTX" {
        Write-Host "Running Citrix server verifications..." -ForegroundColor Magenta
        Write-Output $NewLines
        # Add Citrix-specific verification steps here
        1OrganizationalUnit
        2PowershellVersion
        5EnableAdminApprovalMode
        6Enable8.3FileNameCreation
        7DisableWindowsDFSS
        8DNSSuffixCompletionPolicy
    }
    "APP" {
        Write-Host "Running App server verifications..." -ForegroundColor Magenta
        Write-Output $NewLines
        # Add App-specific verification steps here
        1OrganizationalUnit
        2PowershellVersion
        3.NETFrameworkForMatrikon
        4InstallRDSH
        5EnableAdminApprovalMode
        6Enable8.3FileNameCreation
        7DisableWindowsDFSS
        8DNSSuffixCompletionPolicy
    }
    "GW" {
        Write-Host "Running Gateway server verifications..." -ForegroundColor Magenta
        Write-Output $NewLines
        # Add Gateway-specific verification steps here
        1OrganizationalUnit
        2PowershellVersion
        4InstallRDSH
        5EnableAdminApprovalMode
        6Enable8.3FileNameCreation
        7DisableWindowsDFSS
        8DNSSuffixCompletionPolicy
    }
}



#Zip log folder verifications option
# Function to prompt for Yes/No input
function Get-YesNoInput {
    while ($true) {
        Yellow
        $input = Read-Host "Verifications Complete. Would you like to zip the folder for export? (YES/NO)"
        if ($input -eq "YES" -or $input -eq "NO") {
            return $input
        } else {
            Write-Host "Invalid input. Please enter 'YES' or 'NO'."
        }
    }
}
White
# Get user input
$userInput = Get-YesNoInput

# User input is YES
if ($userInput -eq "YES") {
    
    $DestinationZipPath = "D:\"+$ServerName+"_InstallationPrerequisiteVerifications.zip"

    # Create a zip file from the folder
    Compress-Archive -Path $VerificationPath -DestinationPath $DestinationZipPath

    Write-Host "`nFolder zipped successfully. Zip file created at: $DestinationZipPath" -ForegroundColor White
} else {
    Write-Host "`nNo action taken. Exiting script." -ForegroundColor White
}
Write-Host "`nScript execution complete.  Press Enter to close." -ForegroundColor Yellow
White
PAUSE