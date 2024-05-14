$ErrorActionPreference= 'silentlycontinue'
$IgnoreList = @("ExampleUser1", "ExampleUser2")

# Get all user profiles
$userProfiles = Get-WmiObject -Class Win32_UserProfile

$totalItemCount = $userProfiles.Count
$processedItemCount = 0

foreach ($userProfile in $userProfiles) {
    $profilePath = $userProfile.LocalPath
    $username = Split-Path $profilePath -Leaf

    # Skip if the username is in the IgnoreList
    if ($IgnoreList -contains $username) {
        Write-Host "Skipping deletion of user profile for $username (in IgnoreList)."
        continue
    }

    # Unload the user profile if it's loaded
    $loadedProfile = Get-WmiObject -Class Win32_UserProfile | Where-Object { $_.LocalPath -eq $profilePath -and $_.Loaded -eq $true }
    if ($loadedProfile -ne $null) {
        Write-Host "Unloading loaded profile for $username..."
        $loadedProfile.Unload()
    }

    # Delete the user profile
    Write-Host "Deleting user profile for $username..."
    $userProfile.Delete()
    Write-Host "User profile for $username deleted successfully."
    $processedItemCount++
    Write-Host "Processed $processedItemCount out of $totalItemCount items"
}
