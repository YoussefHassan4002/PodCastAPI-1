# GitHub Actions Deployment Setup Guide

This guide will help you set up automated deployment to MonsterASP.net using GitHub Actions.

## Prerequisites

1. ✅ Your code is in a GitHub repository
2. ✅ WebDeploy is enabled in MonsterASP.net control panel
3. ✅ You have your `.publishSettings` file with deployment credentials

## Step 1: Add GitHub Secrets

Go to your GitHub repository and add the following secrets:

**Repository Settings → Secrets and variables → Actions → New repository secret**

Add these 4 secrets based on your `.publishSettings` file:

| Secret Name | Value from .publishSettings | Example Value |
|------------|----------------------------|---------------|
| `WEBSITE_NAME` | `msdeploySite` attribute | `site49966` |
| `SERVER_COMPUTER_NAME` | `publishUrl` attribute | `site49966.siteasp.net` |
| `SERVER_USERNAME` | `userName` attribute | `site49966` |
| `SERVER_PASSWORD` | `userPWD` attribute | `yS-7+5Gq2Ff_` |

**Your specific values:**
- `WEBSITE_NAME`: `site49966`
- `SERVER_COMPUTER_NAME`: `site49966.siteasp.net`
- `SERVER_USERNAME`: `site49966`
- `SERVER_PASSWORD`: `yS-7+5Gq2Ff_`

⚠️ **Important**: Never commit these credentials to your repository. They should only be stored as GitHub Secrets.

## Step 2: Verify Workflow File

The workflow file `.github/workflows/publish.yml` has been created and configured for your project. It will:

1. ✅ Checkout your code
2. ✅ Setup .NET 8.0
3. ✅ Restore dependencies
4. ✅ Build in Release configuration
5. ✅ Publish to `./publish` folder
6. ✅ Deploy to MonsterASP.net via WebDeploy

## Step 3: Commit and Push

1. Commit the workflow file:
   ```bash
   git add .github/workflows/publish.yml
   git commit -m "Add GitHub Actions deployment workflow"
   git push
   ```

2. The workflow will automatically trigger on push to `main` or `master` branch.

## Step 4: Monitor Deployment

1. Go to your GitHub repository
2. Click on the **Actions** tab
3. You'll see the workflow run in progress
4. Click on the run to see detailed logs
5. Green checkmark = successful deployment ✅

## Step 5: Manual Trigger (Optional)

You can also manually trigger the workflow:

1. Go to **Actions** tab
2. Select **Build, publish and deploy to MonsterASP.NET** workflow
3. Click **Run workflow** button
4. Select branch and click **Run workflow**

## Troubleshooting

### Workflow Fails at Deploy Step

**Error: Authentication failed**
- Verify your secrets are correct
- Check if WebDeploy is enabled in MonsterASP.net control panel
- Ensure credentials haven't changed

**Error: Connection timeout**
- Verify `SERVER_COMPUTER_NAME` is correct
- Check if port 8172 is accessible
- Contact MonsterASP.net support if WebDeploy service is down

### Deployment Succeeds but Site Shows 403.14 Error

This error indicates IIS configuration issues, not deployment problems:

**Symptoms:**
- HTTP Error 403.14 - Forbidden
- "The Web server is configured to not list the contents of this directory"

**Solutions:**

1. **Check web.config exists**: Ensure `web.config` is deployed (ASP.NET Core should generate this automatically)

2. **Verify ASP.NET Core Module**: Contact MonsterASP.net support to ensure:
   - ASP.NET Core Hosting Bundle is installed
   - ASP.NET Core Module is configured for your site

3. **Check Application Pool**: In MonsterASP.net control panel:
   - Ensure Application Pool is set to `.NET CLR Version: No Managed Code`
   - Application Pool should target .NET 8.0 runtime

4. **Verify Default Document**: The site should route to your API, not try to list directories

5. **Check Physical Path**: Verify files are deployed to correct location (`D:\Sites\site49966\wwwroot`)

**Contact MonsterASP.net Support** with:
- Your site name: `site49966`
- Error: 403.14 Forbidden
- Request: Configure ASP.NET Core 8.0 hosting for the site

## Workflow Customization

### Change Trigger Branch

Edit `.github/workflows/publish.yml`:

```yaml
on:
  push:
    branches:
      - main  # Change to your branch name
```

### Add Tests

Add this step before the Deploy step:

```yaml
- name: Run tests
  run: dotnet test --configuration Release --no-build
```

### Deploy Only on Tags

```yaml
on:
  push:
    tags:
      - 'v*'
```

## Next Steps

After successful deployment:

1. ✅ Test your API endpoints
2. ✅ Verify database connection
3. ✅ Check Swagger UI (if enabled)
4. ✅ Monitor application logs in MonsterASP.net control panel

## Security Notes

- ✅ Secrets are encrypted and only accessible during workflow runs
- ✅ Never commit `.publishSettings` file to repository
- ✅ Use `.gitignore` to exclude sensitive files
- ✅ Rotate deployment passwords periodically
