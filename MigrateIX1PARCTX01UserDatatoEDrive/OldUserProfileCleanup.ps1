##############################
#Description: This script will back up Users' directories from C:\Users to E:\Users_Archive, excluding C:\Users\$UserID\AppData.
#             Once the backup process is complete, the User Profile is deleted, whiping all remaining data in C:\Users\$UserID.
#             The $IgnoreList variable contains Users/Profiles that belong to certain admin and specialized accounts and should not be deleted.
#
#Author: Christopher DeAngelis
#Date: 6/12/2023
##############################

$sourcePath = "C:\Users"
$destinationPath = "E:\Users_Archive"

$IgnoreList = @("AWSSMAGENT_USER", "azsqlconnect", "azure_migration@am.lilly.com", "AZR-DRMIGRATE-SP", "CitrixTelemetryService", "CTRXGLBSRVC", "ctxz1dbadmin", "CTXZ1XDPVS", "Default", "Default2", "express2@am.lilly.com", "GMPNTBATCH", "IGNIOWIN", "indypar_toolsaccount", "iparipad052", "IPM_DENODO_DEV", "ip_pmxadmin", "LocAdm", "LocalService", "MQIDS_O365", "NetworkService", "OASISUSER", "systemprofile"
)

###################################################################################
#STEP 1
#Backup Users Folder that is older than a Year to E: Drive - Exclude AppData Folder
###################################################################################

# Get the users whose dirs have not been modified in over a year from the source directory, excluding $IgnoreList
$users = Get-ChildItem -Path $sourcePath | Where-Object { $_.Name -notin $IgnoreList -and $_.LastWriteTime -lt (Get-Date).AddDays(-365)}

$totalItemCount_move = $users.Count
$processedItemCount_move = 0

# Create the destination directory if it doesn't exist
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Force -Path $destinationPath
}

# Move each user's folder to the destination directory
foreach ($user in $users) {
    $userPath = Join-Path -Path $sourcePath -ChildPath $user.Name
    $newPath = Join-Path -Path $destinationPath -ChildPath $user.Name

    # Exclude the "AppData" folder from the move
    $items = Get-ChildItem -Path $userPath -Recurse | Where-Object { $_.fullName -NotLike "*AppData*" }

    foreach ($item in $items) {
        $relativePath = $item.FullName -replace [regex]::Escape($userPath), ""
        $newItemPath = Join-Path -Path $newPath -ChildPath $relativePath

        # Create the parent directory if it doesn't exist
        $parentDirectory = Split-Path -Path $newItemPath -Parent
        if (!(Test-Path -Path $parentDirectory)) {
            New-Item -ItemType Directory -Force -Path $parentDirectory
        }

        # Move the item to the destination directory
        Move-Item -Path $item.FullName -Destination $newItemPath -Force -ErrorAction:SilentlyContinue
    }

    Write-Host "Move completed for $user"
    $processedItemCount_move++
    Write-Host "Processed $processedItemCount_move out of $totalItemCount_move items"
}

Write-Host "`n`n$totalItemCount_move total items moved."
Write-Host "---------------------------------"
Write-Host "USER DATA BACKUP PROCESS COMPLETE"
Write-Host "---------------------------------`n`n`n"


#########################################
#STEP 2
#Delete Profiles that have been backed up
#########################################

Write-Host "Beginning the Profile Deletion Process...`n"

# Get user profiles that were moved and can now safely be deleted
$targetUsers = Get-ChildItem -Path $destinationPath | Sort-Object LastWriteTime | Select-Object -Last $totalItemCount_move

$totalItemCount_del = $targetUsers.Count
$processedItemCount_del = 0

foreach ($targetUser in $targetUsers) {
    # Check if the user profile exists
    $userProfile = Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.EndsWith("\$targetUser") }
    if ($userProfile -eq $null) {
        Write-Host "User profile not found for $targetUser."
    } else {
        # Unload the user profile if it's loaded
        $loadedProfile = Get-CimInstance -Class Win32_UserProfile | Where-Object { $_.LocalPath.EndsWith("\$targetUser") -and $_.Loaded -eq $true }
        if ($loadedProfile -ne $null) {
            Write-Host "Unloading loaded profile for $targetUser..."
            foreach ($profile in $loadedProfile) {
                # Define the username of the user you want to log off
                $usernameToLogOff = Split-Path $loadedProfile.LocalPath -Leaf

                # Get the session ID associated with the username
                $session = quser | Where-Object { $_ -match $usernameToLogOff }
                if ($session) {
                    $sessionId = $session -split '\s+' | Select-Object -Index 2

                    # Log off the user by session ID
                    logoff $sessionId
                    }
            }
        }

        # Delete the user profile
        Write-Host "Deleting user profile for $targetUser..."
        foreach ($profile in $userProfile) {
            Remove-CimInstance -CimInstance $profile
        }
        Write-Host "User profile for $targetUser deleted successfully."
    }
    $processedItemCount_del++
    Write-Host "Processed $processedItemCount_del out of $totalItemCount_del items"
}

Write-Host "`n`n---------------------------------"
Write-Host "PROFILE DELETION PROCESS COMPLETE"
Write-Host "---------------------------------"

Write-Host "`n`nScript completed. Press Enter to exit."
Read-Host