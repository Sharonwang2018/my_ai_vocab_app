# 🚀 立即部署指南

## ✅ 已完成的工作

1. **代码更新**
   - ✅ 真实图片生成（基于单词描述）
   - ✅ Enter 键搜索功能
   - ✅ 图片显示改进（完整显示、加载状态、错误处理）
   - ✅ 所有代码已推送到 GitHub

2. **功能改进**
   - ✅ ProbeX API 代理集成
   - ✅ 图片生成从卡通风格改为真实风格
   - ✅ 前端用户体验改进

## ❌ 待完成的部署

### 1. 部署 Supabase Edge Functions

需要在 Supabase Dashboard 中更新两个函数：

#### 更新 search-word 函数

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/search-word
2. 点击 "Edit" 或直接在编辑器中
3. 复制以下文件的完整内容：
   ```
   /Users/ss/my_ai_vocab_app/supabase/functions/search-word/index.ts
   ```
4. 粘贴替换现有代码
5. 点击 "Deploy"

#### 更新 generate-story 函数

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/generate-story
2. 点击 "Edit"
3. 复制以下文件的完整内容：
   ```
   /Users/ss/my_ai_vocab_app/supabase/functions/generate-story/index.ts
   ```
4. 粘贴替换现有代码
5. 点击 "Deploy"

### 2. 重新构建和部署前端应用

#### 方式 1: 本地构建 + S3 部署

```bash
cd /Users/ss/my_ai_vocab_app

# 构建 Flutter Web
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xsqeicialxvfzfzxjorn.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzcWVpY2lhbHh2Znpmenhqb3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3ODA2ODIsImV4cCI6MjA3OTM1NjY4Mn0.hIOzK-O1yohy1bGsOIK0p3ttJMePfS9NHzVs1GE2-Xg

# 部署到 S3
aws s3 sync build/web s3://my-ai-vocab-app-deploy --delete
```

#### 方式 2: 使用 AWS Amplify（如果配置了）

如果 Amplify 已配置环境变量，它会自动从 GitHub 拉取最新代码并重新构建。

1. 访问: https://console.aws.amazon.com/amplify
2. 选择应用
3. 点击 "Redeploy this version" 或等待自动部署

## 🧪 验证部署

### 测试后端函数

```bash
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "apple"}'
```

检查：
- ✅ 返回单词信息
- ✅ 图片 URL 包含 "realistic" 或 "flux"
- ✅ 图片 URL 基于单词描述生成

### 测试前端应用

访问: http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com

测试：
- ✅ 输入单词后按 Enter 键可以搜索
- ✅ 图片完整显示（不被裁剪）
- ✅ 图片是真实风格（不是卡通）
- ✅ 图片加载时显示进度

## 📋 快速检查清单

- [ ] 更新 search-word 函数到 Supabase Dashboard
- [ ] 更新 generate-story 函数到 Supabase Dashboard
- [ ] 重新构建前端应用
- [ ] 部署前端到 S3
- [ ] 测试搜索功能
- [ ] 测试图片显示
- [ ] 测试 Enter 键搜索

## 🎯 完成后的效果

- ✅ 搜索单词显示真实图片（基于描述）
- ✅ 按 Enter 键即可搜索
- ✅ 图片完整显示，有加载状态
- ✅ 所有功能正常工作
