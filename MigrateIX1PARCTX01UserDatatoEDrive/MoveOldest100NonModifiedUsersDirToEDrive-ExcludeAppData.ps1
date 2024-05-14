$sourcePath = "C:\Users"
$destinationPath = "E:\Users_Archive"

$IgnoreList = @("AWSSMAGENT_USER", "azsqlconnect", "azure_migration@am.lilly.com", "CitrixTelemetryService", "CTRXGLBSRVC", "ctxz1dbadmin", "CTXZ1XDPVS", "Default", "Default2", "express2@am.lilly.com", "IGNIOWIN", "indypar_toolsaccount", "iparipad052", "IPM_DENODO_DEV", "LocAdm", "LocalService", "MQIDS_O365", "NetworkService", "OASISUSER"
)

# Create the destination directory if it doesn't exist
if (!(Test-Path -Path $destinationPath)) {
    New-Item -ItemType Directory -Force -Path $destinationPath
}

# Get the oldest 100 users in the source directory, excluding $IgnoreList and "AppData"
$users = Get-ChildItem -Path $sourcePath | Where-Object { $_.Name -notin $IgnoreList } | Sort-Object LastWriteTime | Select-Object -First 100

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

    Write-Host "Move completed for $user"
}

Write-Host "Full move completed"
