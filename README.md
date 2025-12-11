# HTML5 Video Upload Application

This project is an HTML5 video upload application that allows users to upload video files and leave comments. It is built using JavaScript and HTML5, and is designed to be deployed on Azure Web App, with data stored in Azure Cosmos DB and video files in Azure Storage Blob.

## Features

- Video file uploads
- Comment submissions
- Grey background interface
- Local testing capabilities
- Deployment ready for Azure services

## Project Structure

```
html5-video-app
├── src
│   ├── server.js
│   ├── index.js
│   ├── config
│   │   ├── default.json
│   │   └── production.json
│   ├── api
│   │   ├── routes
│   │   │   ├── videos.js
│   │   │   └── comments.js
│   │   ├── controllers
│   │   │   ├── videosController.js
│   │   │   └── commentsController.js
│   │   ├── models
│   │   │   ├── Video.js
│   │   │   └── Comment.js
│   │   └── services
│   │       ├── blobService.js
│   │       └── cosmosService.js
│   └── public
│       ├── index.html
│       ├── styles.css
│       └── app.js
├── tests
│   ├── unit
│   │   ├── server.test.js
│   │   └── api.test.js
│   └── integration
│       └── upload.test.js
├── azure
│   ├── bicep
│   │   ├── main.bicep
│   │   ├── storage.bicep
│   │   └── cosmosdb.bicep
│   └── templates
│       ├── azuredeploy.json
│       ├── storage-template.json
│       └── cosmos-template.json
├── .github
│   └── workflows
│       └── azure-webapp-deploy.yml
├── .vscode
│   └── launch.json
├── .gitignore
├── .env.example
├── Dockerfile
├── package.json
├── README.md
└── LICENSE
```

## Getting Started

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd html5-video-app
   ```

3. Install dependencies:
   ```
   npm install
   ```

3.1 Optional automated setup (Windows PowerShell):
   ```powershell
   # Create folders, a data file, copy env example, and install dependencies
   powershell -ExecutionPolicy Bypass -File scripts/setup-dev.ps1

   # If you already have node/npm installed and want to skip install step
   powershell -ExecutionPolicy Bypass -File scripts/setup-dev.ps1 -SkipDependencies
   ```

4. Set up environment variables by copying `.env.example` to `.env` and filling in the required values.

5. Run the application locally:
   ```
   npm start
   ```

Optional helper scripts (in `scripts/`):

- **Check development tools:** `npm run check-tools` or `powershell -ExecutionPolicy Bypass -File scripts/check-tools.ps1` — verifies node, npm, git, gh, az, and docker
- **Create a GitHub repo:** `npm run create-repo` — uses `gh` to create a repo and push locally
- **Install Azure CLI:** `scripts/install-az.sh` or `scripts/install-az.ps1` — attempts to install the Azure CLI or prints platform-specific guidance
- **Deploy Bicep templates:** `npm run deploy-bicep` — uses `az` to deploy Bicep templates to the specified resource group
- **Deploy to Azure Web App:** `npm run deploy-azure` — runs `az webapp up` and sets app settings from local environment

Create a GitHub repo and push your code (optional):
```bash
# 1) Create a GitHub repo and push (requires GitHub CLI or create the repo manually in GitHub)
# Make sure you are on the main branch
git branch -M main
# Create using GitHub CLI and push your code:
gh auth login    # (only if you haven't authenticated)
gh repo create <your-username>/html5-video-app --public --source . --remote origin --push

# Or add a remote manually and push
git remote add origin https://github.com/<your-username>/html5-video-app.git
git push -u origin main
```

Local Testing / Try It
```
# Upload a test file (PowerShell uses curl alias; use system curl.exe if needed)
& 'C:\Windows\System32\curl.exe' -i -X POST -F "video=@tests/assets/sample.mp4" http://localhost:3000/api/videos

# Get videos list
& 'C:\Windows\System32\curl.exe' http://localhost:3000/api/videos
```

## Deployment

This application is ready for deployment on Azure. Use the provided Bicep templates and GitHub Actions workflow for seamless deployment to Azure Web App, Cosmos DB, and Azure Storage Blob.

Quick Azure deployment steps:

CI and GitHub Actions
- The `ci.yml` workflow runs tests on `push` and `pull_request` to the `main` branch.
- The `azure-webapp-deploy.yml` workflow runs tests and builds your app, then deploys to Azure Web App after the tests pass.

Deployment options in GitHub Actions:
- Service Principal (recommended): Use `AZURE_CREDENTIALS` secret with the JSON output from `az ad sp create-for-rbac --sdk-auth`. Also set `AZURE_WEBAPP_NAME` and `AZURE_RESOURCE_GROUP`, plus any app settings as secrets (`AZURE_STORAGE_CONNECTION_STRING`, `AZURE_BLOB_CONTAINER`, `AZURE_COSMOS_ENDPOINT`, `AZURE_COSMOS_KEY`). The Actions workflow will use `azure/login@v1` and deploy with the CLI.
- Publish Profile: Provide `AZURE_WEBAPP_PUBLISH_PROFILE` if you prefer to deploy using the publish profile; set `AZURE_WEBAPP_NAME` as well. This is a fallback if you don't use a service principal.

Create a Service Principal and add GitHub secrets (recommended):
1) Run (Cloud Shell or an admin account):
```bash
az ad sp create-for-rbac --name html5video-sp --role contributor --scopes /subscriptions/<SUB_ID> --sdk-auth
```
Copy the JSON output and add it as a GitHub repo secret `AZURE_CREDENTIALS`.
2) Add other repo secrets for the deploy workflow:
   - `AZURE_WEBAPP_NAME` — name of the App Service
   - `AZURE_RESOURCE_GROUP` — resource group name
   - `AZURE_STORAGE_CONNECTION_STRING` — storage connection string
   - `AZURE_BLOB_CONTAINER` — `videos`
   - `AZURE_COSMOS_ENDPOINT` — Cosmos DB endpoint
   - `AZURE_COSMOS_KEY` — Cosmos DB primary key

We provide `scripts/create-sp.sh` to help create a service principal and return the JSON you can paste into GitHub Secrets.

Tips:

## Testing

Run the tests using:
```
npm test
```

## License

This project is licensed under the MIT License. See the LICENSE file for more details.