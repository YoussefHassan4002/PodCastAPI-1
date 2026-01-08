# FTP Deployment script for MonsterASP.net
# Usage: .\deploy-ftp.ps1
# 
# IMPORTANT: Update the FTP credentials below with values from MonsterASP.net control panel

param(
    [string]$FtpServer = "site49966.siteasp.net",  # Get from MonsterASP control panel (e.g., "ftp.site49966.siteasp.net" or IP address)
    [string]$FtpUser = "site49966",     # Get from MonsterASP control panel
    [string]$FtpPass = "Zo5%n3=WQr2?",     # Get from MonsterASP control panel
    [string]$FtpPath = "\wwwroot"    # Remote path (usually "/" for root, or "/wwwroot" depending on hosting)
)

Write-Host "Starting FTP deployment process..." -ForegroundColor Green

# Step 1: Build and Publish
Write-Host "`nStep 1: Building and publishing the application..." -ForegroundColor Yellow
$publishPath = Join-Path $PSScriptRoot "publish"

if (-not (Test-Path $publishPath) -or (Get-ChildItem $publishPath -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
    Write-Host "Publish folder not found or empty. Building..." -ForegroundColor Yellow
    dotnet publish "$PSScriptRoot\Podcast.Api\Podcast.Api.csproj" `
        --configuration Release `
        --output $publishPath

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed! Exiting." -ForegroundColor Red
        exit 1
    }
    Write-Host "Build completed successfully!" -ForegroundColor Green
} else {
    Write-Host "Using existing publish folder." -ForegroundColor Green
}

# Step 2: Validate FTP credentials
if ([string]::IsNullOrWhiteSpace($FtpServer) -or [string]::IsNullOrWhiteSpace($FtpUser) -or [string]::IsNullOrWhiteSpace($FtpPass)) {
    Write-Host "`nERROR: FTP credentials not provided!" -ForegroundColor Red
    Write-Host "`nPlease provide FTP credentials:" -ForegroundColor Yellow
    Write-Host "1. Get FTP credentials from MonsterASP.net control panel" -ForegroundColor Cyan
    Write-Host "2. Run this script with parameters:" -ForegroundColor Cyan
    Write-Host "   .\deploy-ftp.ps1 -FtpServer 'your.ftp.server' -FtpUser 'username' -FtpPass 'password'" -ForegroundColor White
    Write-Host "`nOr edit this script and set the default values at the top." -ForegroundColor Yellow
    exit 1
}

# Step 3: Deploy using FTP
Write-Host "`nStep 2: Deploying to MonsterASP.net via FTP..." -ForegroundColor Yellow
Write-Host "FTP Server: $FtpServer" -ForegroundColor Gray
Write-Host "FTP User: $FtpUser" -ForegroundColor Gray
Write-Host "Remote Path: $FtpPath" -ForegroundColor Gray

# Create FTP URI
$ftpBaseUri = "ftp://$FtpServer$FtpPath"

# Function to create directory on FTP server
function New-FtpDirectory {
    param(
        [string]$FtpUri,
        [System.Net.NetworkCredential]$Credential
    )
    
    try {
        $request = [System.Net.FtpWebRequest]::Create($FtpUri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::MakeDirectory
        $request.Credentials = $Credential
        $request.UsePassive = $true
        $response = $request.GetResponse()
        $response.Close()
        return $true
    }
    catch {
        # Directory might already exist, which is fine
        return $false
    }
}

# Function to upload file
function Send-FtpFile {
    param(
        [string]$LocalPath,
        [string]$RemotePath,
        [System.Net.NetworkCredential]$Credential
    )
    
    try {
        $ftpUri = "$ftpBaseUri$RemotePath"
        $request = [System.Net.FtpWebRequest]::Create($ftpUri)
        $request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
        $request.Credentials = $Credential
        $request.UseBinary = $true
        $request.UsePassive = $true
        
        $fileContent = [System.IO.File]::ReadAllBytes($LocalPath)
        $request.ContentLength = $fileContent.Length
        
        $requestStream = $request.GetRequestStream()
        $requestStream.Write($fileContent, 0, $fileContent.Length)
        $requestStream.Close()
        
        $response = $request.GetResponse()
        $response.Close()
        return $true
    }
    catch {
        Write-Host "Error uploading $RemotePath : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Create credential object
$credential = New-Object System.Net.NetworkCredential($FtpUser, $FtpPass)

# Get all files to upload
$files = Get-ChildItem -Path $publishPath -Recurse -File
$totalFiles = $files.Count
$currentFile = 0
$uploadedCount = 0
$failedCount = 0

Write-Host "`nFound $totalFiles files to upload..." -ForegroundColor Cyan

foreach ($file in $files) {
    $currentFile++
    $relativePath = $file.FullName.Substring($publishPath.Length + 1).Replace('\', '/')
    $remotePath = "/$relativePath"
    
    # Create directory structure if needed
    $remoteDir = Split-Path $remotePath -Parent
    if ($remoteDir -and $remoteDir -ne "/") {
        $dirParts = $remoteDir.TrimStart('/').Split('/')
        $currentDir = ""
        foreach ($part in $dirParts) {
            $currentDir += "/$part"
            New-FtpDirectory -FtpUri "ftp://$FtpServer$currentDir" -Credential $credential | Out-Null
        }
    }
    
    Write-Progress -Activity "Uploading files" -Status "Uploading $relativePath" -PercentComplete (($currentFile / $totalFiles) * 100)
    
    if (Send-FtpFile -LocalPath $file.FullName -RemotePath $remotePath -Credential $credential) {
        $uploadedCount++
        Write-Host "✓ Uploaded: $relativePath" -ForegroundColor Green
    } else {
        $failedCount++
    }
}

Write-Progress -Activity "Uploading files" -Completed

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "FTP Deployment Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total files: $totalFiles" -ForegroundColor White
Write-Host "Uploaded: $uploadedCount" -ForegroundColor Green
Write-Host "Failed: $failedCount" -ForegroundColor $(if ($failedCount -gt 0) { "Red" } else { "Green" })
Write-Host "========================================" -ForegroundColor Cyan

if ($failedCount -eq 0) {
    Write-Host "`n✓ FTP deployment completed successfully!" -ForegroundColor Green
    Write-Host "Your API should be available at: http://podcastapi.runasp.net/" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠ Deployment completed with $failedCount error(s)." -ForegroundColor Yellow
    Write-Host "Please check the error messages above and try again." -ForegroundColor Yellow
    exit 1
}
