# FTP Deployment Guide for MonsterASP.net

This guide explains how to deploy your Podcast API using FTP when MSDeploy is not available.

## Step 1: Get FTP Credentials from MonsterASP.net

1. **Log in to MonsterASP.net Control Panel**
   - Go to your hosting control panel
   - Navigate to **FTP Accounts** or **File Manager** section

2. **Find Your FTP Information:**
   - **FTP Server/Host**: Usually something like `ftp.site49966.siteasp.net` or an IP address
   - **FTP Username**: Your FTP username (might be the same as your hosting username)
   - **FTP Password**: Your FTP password
   - **FTP Port**: Usually `21` (default)
   - **Remote Path**: Usually `/` (root) or `/wwwroot` or `/httpdocs` depending on your hosting

3. **Note these credentials** - you'll need them for the deployment script

## Step 2: Build and Publish Your Application

The FTP script will automatically build and publish, but you can also do it manually:

```powershell
cd Podcast.Api
dotnet publish --configuration Release --output ../publish
```

## Step 3: Deploy Using FTP Script

### Option A: Run with Parameters (Recommended)

```powershell
.\deploy-ftp.ps1 -FtpServer "ftp.site49966.siteasp.net" -FtpUser "your_username" -FtpPass "your_password"
```

**Example:**
```powershell
.\deploy-ftp.ps1 -FtpServer "ftp.site49966.siteasp.net" -FtpUser "site49966" -FtpPass "your_ftp_password"
```

### Option B: Edit the Script

1. Open `deploy-ftp.ps1` in a text editor
2. Find the `param()` section at the top
3. Update the default values:
   ```powershell
   param(
       [string]$FtpServer = "ftp.site49966.siteasp.net",  # Your FTP server
       [string]$FtpUser = "site49966",                     # Your FTP username
       [string]$FtpPass = "your_password",                # Your FTP password
       [string]$FtpPath = "/"                              # Remote path (usually "/")
   )
   ```
4. Save the file
5. Run: `.\deploy-ftp.ps1`

## Step 4: Verify Deployment

After deployment, test your API:

1. **Health Check**: `http://podcastapi.runasp.net/health`
2. **Swagger UI**: `http://podcastapi.runasp.net/swagger`
3. **API Endpoints**: Test your API endpoints

## Troubleshooting

### Connection Timeout
- Verify FTP server address is correct
- Check if your firewall is blocking FTP (port 21)
- Try using passive mode (script uses this by default)

### Authentication Failed
- Double-check username and password
- Ensure credentials are for FTP, not hosting control panel
- Some hosts require full email as username

### Files Not Uploading
- Check if you have write permissions on the remote directory
- Verify the remote path is correct (`/`, `/wwwroot`, `/httpdocs`, etc.)
- Check MonsterASP.net control panel for correct directory structure

### Permission Denied
- Contact MonsterASP.net support to verify FTP permissions
- Ensure your account has write access to the target directory

### Files Uploaded but API Not Working
- Verify `appsettings.Production.json` is uploaded with correct connection string
- Check if `web.config` or similar configuration is needed
- Verify .NET 8.0 runtime is installed on the server
- Check application logs in MonsterASP.net control panel

## Alternative: Manual FTP Upload

If the script doesn't work, you can use an FTP client:

1. **Download an FTP Client:**
   - FileZilla (free): https://filezilla-project.org/
   - WinSCP (free): https://winscp.net/
   - Or use Windows built-in FTP

2. **Connect to FTP Server:**
   - Host: Your FTP server address
   - Username: Your FTP username
   - Password: Your FTP password
   - Port: 21

3. **Upload Files:**
   - Navigate to the root directory (or `/wwwroot`/`/httpdocs` as specified by your host)
   - Upload ALL contents from the `publish` folder
   - Maintain the folder structure

4. **Important Files to Verify:**
   - `Podcast.Api.dll` (main application)
   - `appsettings.json` and `appsettings.Production.json`
   - `web.config` (if present)
   - All `.dll` files in the folder

## Notes

- The script automatically creates directory structure on the server
- Large deployments may take several minutes
- Keep your FTP credentials secure - never commit them to Git
- The `publish` folder contains your compiled application - it's already in `.gitignore`

## Next Steps After FTP Deployment

1. **Run Database Migrations:**
   ```powershell
   dotnet ef database update --project Podcast.Infrastructure --startup-project Podcast.Api
   ```
   (You may need to do this via hosting control panel or contact support)

2. **Configure Production Settings:**
   - Verify `appsettings.Production.json` is on the server
   - Check environment variables if needed

3. **Test the API:**
   - Health endpoint
   - Swagger UI
   - All API endpoints
