# 环境变量配置说明 / Environment Variables Setup

## ✅ 已完成的工作

### 1. 代码清理
- ✅ 已从 `lib/main.dart` 中移除所有硬编码的密钥
- ✅ 代码现在完全依赖环境变量，无默认值
- ✅ 如果环境变量未设置，应用会抛出明确的错误

### 2. Amplify 环境变量配置
- ✅ `SUPABASE_URL`: 已设置
- ✅ `SUPABASE_ANON_KEY`: 已设置

### 3. 部署状态
- ✅ 应用已重新构建（使用环境变量）
- ✅ 应用已重新部署到 S3

## 🔑 密钥配置位置

### Flutter 应用（前端）
环境变量在 **AWS Amplify** 中配置：
- `SUPABASE_URL`: Supabase 项目 URL
- `SUPABASE_ANON_KEY`: Supabase 匿名密钥

### Supabase Edge Functions（后端）
OpenAI 密钥应在 **Supabase 项目** 中配置：
1. 登录 Supabase Dashboard
2. 进入你的项目
3. 导航到 `Settings` -> `Edge Functions` -> `Secrets`
4. 添加环境变量：
   - `OPENAI_API_KEY`: 你的 OpenAI API 密钥

## 🌐 应用访问地址

**当前部署地址（S3）：**
```
http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
```

**Amplify 域名（如果构建成功）：**
```
https://main.d1udenwop4xl8j.amplifyapp.com
```

## 📝 重要说明

1. **所有密钥已从代码中移除** - GitHub 仓库中不再包含任何敏感信息
2. **环境变量在 Amplify 中配置** - 通过 AWS Console 管理，不会泄露到代码中
3. **OpenAI 密钥在 Supabase 中配置** - Edge Functions 使用 Supabase 的环境变量系统

## 🔄 更新环境变量

如果需要更新 Amplify 中的环境变量：

```bash
aws amplify update-app \
  --app-id d1udenwop4xl8j \
  --environment-variables \
    SUPABASE_URL=YOUR_NEW_URL,SUPABASE_ANON_KEY=YOUR_NEW_KEY
```

或在 AWS Amplify Console 中：
1. 访问应用设置
2. 进入 "Environment variables"
3. 编辑或添加变量
4. 保存并重新部署

## ✅ 验证

运行以下命令验证环境变量已正确设置：

```bash
aws amplify get-app --app-id d1udenwop4xl8j --output json | grep -A 10 environmentVariables
```


