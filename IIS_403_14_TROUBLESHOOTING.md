# Troubleshooting HTTP 403.14 Error on MonsterASP.net

## Error Description

**HTTP Error 403.14 - Forbidden**
- **Message**: "The Web server is configured to not list the contents of this directory."
- **URL**: `http://podcastapi.runasp.net:80/`
- **Physical Path**: `D:\Sites\site49966\wwwroot`

## Root Cause

This error occurs when IIS cannot properly serve your ASP.NET Core application. IIS is trying to list directory contents instead of executing your application, which indicates:

1. **ASP.NET Core Module not configured** - IIS doesn't know how to handle .NET 8.0 requests
2. **Application Pool misconfiguration** - Wrong .NET CLR version or runtime
3. **Missing or incorrect web.config** - IIS can't find the application entry point
4. **ASP.NET Core Hosting Bundle not installed** - Required runtime components missing

## Solutions

### Solution 1: Contact MonsterASP.net Support (Recommended)

**This is the most reliable solution.** Contact MonsterASP.net support and provide them with:

```
Subject: ASP.NET Core 8.0 Configuration Required for site49966

Hello,

I have deployed an ASP.NET Core 8.0 Web API application to site49966, but I'm receiving HTTP 403.14 errors.

Please configure the following:

1. **Install/Verify ASP.NET Core 8.0 Hosting Bundle**
   - Ensure ASP.NET Core 8.0 Runtime and Hosting Bundle is installed on the server
   - Download: https://dotnet.microsoft.com/download/dotnet/8.0

2. **Configure Application Pool**
   - Site: site49966
   - Application Pool: Set to ".NET CLR Version: No Managed Code"
   - Enable 32-bit Applications: False (for x64 deployment)
   - Managed Pipeline Mode: Integrated

3. **Verify web.config**
   - Location: D:\Sites\site49966\wwwroot\web.config
   - Should reference AspNetCoreModuleV2
   - Process path should point to Podcast.Api.dll

4. **Verify Site Configuration**
   - Physical Path: D:\Sites\site49966\wwwroot
   - Default Document: Not required (ASP.NET Core handles routing)
   - Directory Browsing: Disabled (correct)

5. **Check Application Pool Identity**
   - Ensure the application pool has read/execute permissions on wwwroot folder

Site Details:
- Site Name: site49966
- URL: http://podcastapi.runasp.net/
- Framework: .NET 8.0
- Deployment Method: WebDeploy

Thank you!
```

### Solution 2: Verify web.config is Deployed

Ensure `web.config` exists in the root of your deployment (`wwwroot` folder). It should contain:

```xml
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <location path="." inheritInChildApplications="false">
    <system.webServer>
      <handlers>
        <add name="aspNetCore" path="*" verb="*" modules="AspNetCoreModuleV2" resourceType="Unspecified" />
      </handlers>
      <aspNetCore processPath="dotnet" 
                  arguments=".\Podcast.Api.dll" 
                  stdoutLogEnabled="true" 
                  stdoutLogFile=".\logs\stdout" 
                  hostingModel="inprocess" />
    </system.webServer>
  </location>
</configuration>
```

**Note**: The GitHub Actions workflow automatically generates this file during publish.

### Solution 3: Check Deployment Files

Verify these files exist in `D:\Sites\site49966\wwwroot`:

- ✅ `web.config` (IIS configuration)
- ✅ `Podcast.Api.dll` (Main application DLL)
- ✅ `Podcast.Api.exe` (Executable - for in-process hosting)
- ✅ `Podcast.Api.runtimeconfig.json` (Runtime configuration)
- ✅ `appsettings.json` (Application settings)
- ✅ `appsettings.Production.json` (Production settings)

### Solution 4: Enable Logging (Temporary Debug)

If you have access to modify `web.config`, enable stdout logging:

```xml
<aspNetCore processPath="dotnet" 
            arguments=".\Podcast.Api.dll" 
            stdoutLogEnabled="true" 
            stdoutLogFile=".\logs\stdout" 
            hostingModel="inprocess" />
```

Then check `D:\Sites\site49966\wwwroot\logs\stdout_*.log` for errors.

### Solution 5: Verify Application Pool Settings

If you have access to IIS Manager (via MonsterASP.net control panel):

1. **Application Pool Settings**:
   - .NET CLR Version: **No Managed Code** (Critical!)
   - Managed Pipeline Mode: **Integrated**
   - Start Mode: **AlwaysRunning** (optional, for better performance)

2. **Site Settings**:
   - Physical Path: `D:\Sites\site49966\wwwroot`
   - Binding: HTTP on port 80
   - Application Pool: Should match your site's pool

## Common Issues

### Issue: "Handler not found"
**Cause**: ASP.NET Core Module not installed  
**Fix**: Contact MonsterASP.net to install ASP.NET Core 8.0 Hosting Bundle

### Issue: "500.0 - ANCM In-Process Handler Load Failure"
**Cause**: Application pool misconfiguration or missing runtime  
**Fix**: Verify Application Pool uses "No Managed Code" and .NET 8.0 runtime is installed

### Issue: "500.30 - ANCM In-Process Start Failure"
**Cause**: Application startup error  
**Fix**: Check application logs, verify database connection string, check appsettings.json

### Issue: Files deployed but still 403.14
**Cause**: IIS not recognizing ASP.NET Core application  
**Fix**: Verify web.config exists and Application Pool is configured correctly

## Verification Steps

After MonsterASP.net configures the server:

1. **Test Health Endpoint**:
   ```
   http://podcastapi.runasp.net/health
   ```
   Should return: `Healthy`

2. **Test Swagger**:
   ```
   http://podcastapi.runasp.net/swagger
   ```
   Should show Swagger UI

3. **Test API Endpoint**:
   ```
   http://podcastapi.runasp.net/api/podcasts
   ```
   Should return API response (or 401 if authentication required)

## Prevention for Future Deployments

1. ✅ **GitHub Actions Workflow** - Automatically generates correct `web.config`
2. ✅ **Proper Publish Settings** - Uses `--runtime win-x64` for Windows deployment
3. ✅ **web.config Auto-generation** - ASP.NET Core SDK creates it automatically

## Next Steps

1. **Immediate**: Contact MonsterASP.net support with the information above
2. **Verify**: Once configured, test all endpoints
3. **Monitor**: Check application logs for any runtime errors
4. **Document**: Note any custom configurations needed for future reference

## Additional Resources

- [ASP.NET Core Module Configuration Reference](https://learn.microsoft.com/en-us/aspnet/core/host-and-deploy/aspnet-core-module)
- [Troubleshoot ASP.NET Core on IIS](https://learn.microsoft.com/en-us/aspnet/core/test/troubleshoot-azure-iis)
- [ASP.NET Core Hosting Bundle](https://dotnet.microsoft.com/download/dotnet/8.0)

---

**Note**: The 403.14 error is a server configuration issue, not a deployment issue. Your files are likely deployed correctly, but IIS needs to be configured to run ASP.NET Core 8.0 applications.
