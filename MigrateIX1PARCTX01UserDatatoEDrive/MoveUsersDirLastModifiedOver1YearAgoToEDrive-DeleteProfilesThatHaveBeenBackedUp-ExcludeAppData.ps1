$sourcePath = "C:\Users"
$destinationPath = "E:\Users_Archive"

$IgnoreList = @("AWSSMAGENT_USER", "azsqlconnect", "azure_migration@am.lilly.com", "CitrixTelemetryService", "CTRXGLBSRVC", "ctxz1dbadmin", "CTXZ1XDPVS", "Default", "Default2", "express2@am.lilly.com", "IGNIOWIN", "indypar_toolsaccount", "iparipad052", "IPM_DENODO_DEV", "LocAdm", "LocalService", "MQIDS_O365", "NetworkService", "OASISUSER"
)

$totalItemCount = $users.Count
$processedItemCount = 0

# Create the destination directory if it doesn't exist
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Force -Path $destinationPath
}

# Get the users whose dirs have not been modified in over a year from the source directory, excluding $IgnoreList
$users = Get-ChildItem -Path $sourcePath | Where-Object { $_.Name -notin $IgnoreList -and $_.LastWriteTime -lt (Get-Date).AddDays(-365)}

# Move each user's folder to the destination directory
foreach ($user in $users) {
    $userPath = Join-Path -Path $sourcePath -ChildPath $user.Name
    $newPath = Join-Path -Path $destinationPath -ChildPath $user.Name

    # Exclude the "AppData" folder from the move
    $items = Get-ChildItem -Path $userPath -Recurse | Where-Object { $_.FullName -notlike "*\\AppData\\*" }

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
    Write-Host "Move completed for $userPath"
    $processedItemCount++
    Write-Host "Processed $processedItemCount out of $totalItemCount items"
}

Write-Host "Full move complete"
Write-Host "$totalItemCount total items moved."
