# Firebase Service Account Setup Instructions

## Step 1: Create Service Account in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `pegas-pos`
3. Navigate to "IAM & Admin" > "Service Accounts"
4. Click "CREATE SERVICE ACCOUNT"
5. Fill in:
   - Service account name: `github-actions`
   - Service account ID: `github-actions` (auto-generated)
   - Description: `Service account for GitHub Actions deployment`
6. Click "CREATE AND CONTINUE"

## Step 2: Assign Roles

Add these roles to the service account:
- `Firebase Hosting Admin`
- `Cloud Build Service Account`
- `Firebase Admin SDK Service Agent`

## Step 3: Create and Download Key

1. Click on the created service account
2. Go to "Keys" tab
3. Click "ADD KEY" > "Create new key"
4. Choose "JSON" format
5. Download the key file

## Step 4: Add to GitHub Secrets

1. Go to your GitHub repository: https://github.com/RusthyAhd/POS-App
2. Go to Settings > Secrets and variables > Actions
3. Click "New repository secret"
4. Name: `FIREBASE_SERVICE_ACCOUNT_PEGAS_POS`
5. Value: Copy and paste the entire contents of the JSON key file
6. Click "Add secret"

## Alternative: Using Firebase CLI (Simpler Method)

If you prefer, you can use this command to set up automatically:
```bash
firebase init hosting:github
```

Follow the prompts and it will:
1. Create the service account
2. Add the secret to GitHub
3. Create workflow files

## Testing

Once set up, any push to the main branch will trigger automatic deployment!