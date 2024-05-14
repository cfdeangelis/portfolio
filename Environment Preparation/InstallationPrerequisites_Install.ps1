#Installation Prerequisites_Before Restart Script
#Created on 03-MAY-2024
#Created by Christopher DeAngelis (L010436)

#########################################################################################################################################################

#Global Variables
$NewLines = "`n" * 5

#Global Functions
function Yellow {
    $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::Yellow
}

function White {
    $Host.UI.RawUI.ForegroundColor = [System.ConsoleColor]::White
}

#Installation Functions
function 4InstallRDSH {
    Write-Host "Installing the Remote Desktop Session Host role..." -Foregroundcolor Green
    Install-WindowsFeature -Name RDS-RD-Server -IncludeAllSubFeature
    Write-Output $NewLines
}

function 5EnableAdminApprovalMode {
    Write-Host "Enabling the Admin Approval Mode policy..." -Foregroundcolor Green
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name FilterAdministratorToken -Value 1 -Type DWORD
    gpupdate /force
    Write-Output $NewLines
}

function 6Enable8.3FileNameCreation {
    Write-Host "Enabling 8.3 file name creation..." -Foregroundcolor Green
    fsutil.exe behavior set disable8dot3 0
    Write-Output $NewLines
}

function 7DisableWindowsDFSS {
    Write-Host "Disabling Windows DFSS..." -Foregroundcolor Green
    
    # Function to create registry key if it doesn't exist
    function New-RegistryKeyIfNotExists {
        param(
            [string]$Path
        )

        if (-not (Test-Path $Path)) {
            New-Item -Path $Path -Force
        }
    }

    # Create registry keys if they don't exist
    New-RegistryKeyIfNotExists -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Quota System"
    New-RegistryKeyIfNotExists -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TSFairShare\Disk"
    New-RegistryKeyIfNotExists -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TSFairShare\NetFS"

    # Set registry values
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Quota System" -Name "EnableCpuQuota" -Value 0 -Type DWORD
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TSFairShare\Disk" -Name "EnableFairShare" -Value 0 -Type DWORD
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TSFairShare\NetFS" -Name "EnableFairShare" -Value 0 -Type DWORD

    Write-Output $NewLines

}

function 8DNSSuffixCompletionPolicy {
    function Get-YesNoInput {
        while ($true) {
           Yellow
            $input = Read-Host "Do you want to configure the DNS Suffix Completion Policy? (Check REF_DOC_NwDesign, Section ND-GPEDIT-CF-01) (YES/NO)"
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

    # Specify the desired value (Enable = 1, Not Configured = 0)
    if ($userInput -eq "YES") {
        $valueData = 1  # Enable

        # Check if the registry value exists, create it if not
        if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient")) {
            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
        }
    } else {
        $valueData = 0  # Not Configured
    }

    # Set the registry value
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "AppendToMultiLabelName" -Value $valueData -Type DWORD
    Write-Output $NewLines
}

#########################################################################################################################################################

#BEGINNING OF SCRIPT

Write-Output "`n`n"
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
# Get user input for server type
$serverType = Get-ServerTypeInput
Write-Output $NewLines

# Run appropriate scripts based on server type
switch ($serverType) {
    "CTX" {
        White
        Write-Host "Running Citrix server prerequisites..." -ForegroundColor Magenta
        Write-Output $NewLines
        # Add Citrix-specific installation steps here
        5EnableAdminApprovalMode
        6Enable8.3FileNameCreation
        7DisableWindowsDFSS
        8DNSSuffixCompletionPolicy
    }
    "APP" {
        White
        Write-Host "Running App server prerequisites..." -ForegroundColor Magenta
        Write-Output $NewLines
        # Add App-specific installation steps here
        4InstallRDSH
        5EnableAdminApprovalMode
        6Enable8.3FileNameCreation
        7DisableWindowsDFSS
        8DNSSuffixCompletionPolicy
    }
    "GW" {
        White
        Write-Host "Running Gateway server prerequisites..." -ForegroundColor Magenta
        Write-Output $NewLines
        # Add Gateway-specific installation steps here
        4InstallRDSH
        5EnableAdminApprovalMode
        6Enable8.3FileNameCreation
        7DisableWindowsDFSS
        8DNSSuffixCompletionPolicy
    }
}



#####################################################################################################################


Write-Host "Restart is required.  Please press ENTER to restart." -ForegroundColor Yellow
White
PAUSE
Restart-Computer -Force