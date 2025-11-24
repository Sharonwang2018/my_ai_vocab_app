# AWS Amplify 部署指南 / AWS Amplify Deployment Guide

## 中文说明

### 前置要求
1. 代码已推送到 GitHub: https://github.com/Sharonwang2018/my_ai_vocab_app
2. AWS 账户已创建
3. 需要为 AWS 用户添加 Amplify 权限

### 步骤 1: 添加 AWS IAM 权限

1. 登录 AWS Console: https://console.aws.amazon.com
2. 进入 IAM 服务
3. 选择用户 `awsuser`
4. 点击 "Add permissions" -> "Attach policies directly"
5. 搜索并添加以下策略：
   - `AmplifyFullAccess` (或至少包含 `amplify:CreateApp`, `amplify:CreateBranch`, `amplify:CreateDeployment` 等权限)

### 步骤 2: 在 AWS Amplify Console 创建应用

1. 访问 AWS Amplify Console: https://console.aws.amazon.com/amplify
2. 点击 "New app" -> "Host web app"
3. 选择 "GitHub" 作为源代码提供者
4. 授权 GitHub 访问（如果尚未授权）
5. 选择仓库: `Sharonwang2018/my_ai_vocab_app`
6. 选择分支: `main`
7. 应用名称: `my-ai-vocab-app`

### 步骤 3: 配置构建设置

Amplify 会自动检测 `amplify.yml` 文件，但需要确保环境变量已设置：

1. 在 Amplify Console 中，进入你的应用
2. 点击左侧菜单 "App settings" -> "Environment variables"
3. 添加以下环境变量：
   - `SUPABASE_URL` = `https://xsqeicialxvfzfzxjorn.supabase.co`
   - `SUPABASE_ANON_KEY` = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzcWVpY2lhbHh2Znpmenhqb3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3ODA2ODIsImV4cCI6MjA3OTM1NjY4Mn0.hIOzK-O1yohy1bGsOIK0p3ttJMePfS9NHzVs1GE2-Xg`

### 步骤 4: 部署

1. 点击 "Save and deploy"
2. Amplify 会自动开始构建和部署
3. 构建完成后，你会获得一个域名，格式类似: `https://main.xxxxx.amplifyapp.com`

### 步骤 5: 获取域名

部署完成后，在 Amplify Console 的 "App settings" -> "Domains" 中可以看到你的应用域名。

---

## English Instructions

### Prerequisites
1. Code pushed to GitHub: https://github.com/Sharonwang2018/my_ai_vocab_app
2. AWS account created
3. Need to add Amplify permissions to AWS user

### Step 1: Add AWS IAM Permissions

1. Login to AWS Console: https://console.aws.amazon.com
2. Go to IAM service
3. Select user `awsuser`
4. Click "Add permissions" -> "Attach policies directly"
5. Search and add the following policy:
   - `AmplifyFullAccess` (or at minimum include permissions like `amplify:CreateApp`, `amplify:CreateBranch`, `amplify:CreateDeployment`)

### Step 2: Create App in AWS Amplify Console

1. Visit AWS Amplify Console: https://console.aws.amazon.com/amplify
2. Click "New app" -> "Host web app"
3. Select "GitHub" as source provider
4. Authorize GitHub access (if not already done)
5. Select repository: `Sharonwang2018/my_ai_vocab_app`
6. Select branch: `main`
7. App name: `my-ai-vocab-app`

### Step 3: Configure Build Settings

Amplify will automatically detect the `amplify.yml` file, but you need to ensure environment variables are set:

1. In Amplify Console, go to your app
2. Click "App settings" -> "Environment variables"
3. Add the following environment variables:
   - `SUPABASE_URL` = `https://xsqeicialxvfzfzxjorn.supabase.co`
   - `SUPABASE_ANON_KEY` = `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzcWVpY2lhbHh2Znpmenhqb3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3ODA2ODIsImV4cCI6MjA3OTM1NjY4Mn0.hIOzK-O1yohy1bGsOIK0p3ttJMePfS9NHzVs1GE2-Xg`

### Step 4: Deploy

1. Click "Save and deploy"
2. Amplify will automatically start building and deploying
3. After build completes, you'll get a domain like: `https://main.xxxxx.amplifyapp.com`

### Step 5: Get Domain

After deployment completes, you can see your app domain in Amplify Console under "App settings" -> "Domains".

---

## 自动化脚本 (需要权限后运行) / Automated Script (Run after permissions added)

如果已添加权限，可以运行以下命令自动创建应用：

```bash
aws amplify create-app \
  --name my-ai-vocab-app \
  --repository https://github.com/Sharonwang2018/my_ai_vocab_app \
  --platform WEB \
  --environment-variables \
    SUPABASE_URL=https://xsqeicialxvfzfzxjorn.supabase.co,SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzcWVpY2lhbHh2Znpmenhqb3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3ODA2ODIsImV4cCI6MjA3OTM1NjY4Mn0.hIOzK-O1yohy1bGsOIK0p3ttJMePfS9NHzVs1GE2-Xg

# 然后创建分支和部署
APP_ID=$(aws amplify list-apps --query 'apps[0].appId' --output text)
aws amplify create-branch --app-id $APP_ID --branch-name main
aws amplify start-job --app-id $APP_ID --branch-name main --job-type RELEASE
```

