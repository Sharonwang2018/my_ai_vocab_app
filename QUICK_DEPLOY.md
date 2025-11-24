# 快速部署指南 - 从 Supabase Dashboard

## 当前状态
你已经在 Supabase Dashboard 中。现在需要完成以下步骤：

## 步骤 1: 获取 Service Role Key

1. 在左侧导航栏，点击 **"API Keys"**（在 PROJECT SETTINGS 下）
2. 找到 **"service_role"** key（⚠️ 这是敏感密钥，不要泄露）
3. 复制这个 key，稍后会用到

## 步骤 2: 配置 Edge Functions Secrets

1. 在左侧导航栏，点击 **"Edge Functions"**（在 CONFIGURATION 下）
2. 点击 **"Secrets"** 标签
3. 添加以下环境变量：
   - **OPENAI_API_KEY**: 你的 OpenAI API 密钥
   - **SUPABASE_SERVICE_ROLE_KEY**: 刚才复制的 service_role key

## 步骤 3: 部署 Edge Functions

### 方式 A: 使用命令行（推荐）

```bash
cd /Users/ss/my_ai_vocab_app

# 1. 登录 Supabase（如果还没登录）
supabase login

# 2. 链接项目
supabase link --project-ref xsqeicialxvfzfzxjorn

# 3. 设置 Secrets（使用你在 Dashboard 中设置的密钥）
supabase secrets set OPENAI_API_KEY=你的_openai_密钥
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=你的_service_role_密钥

# 4. 部署函数
supabase functions deploy search-word
supabase functions deploy generate-story
```

### 方式 B: 使用部署脚本

```bash
cd /Users/ss/my_ai_vocab_app
./deploy-supabase-functions.sh
```

脚本会引导你完成所有步骤。

## 步骤 4: 验证部署

部署成功后，访问应用：
```
http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
```

尝试搜索一个单词（如 "volcano"），应该可以正常工作了！

## 故障排除

如果遇到问题：

1. **检查 Secrets 是否设置正确**
   - 在 Dashboard -> Edge Functions -> Secrets 中确认

2. **检查函数是否部署**
   - 在 Dashboard -> Edge Functions 中应该能看到 `search-word` 和 `generate-story`

3. **查看函数日志**
   - 在 Dashboard -> Edge Functions -> 选择函数 -> Logs

4. **测试函数**
   - 函数 URL:
     - `https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word`
     - `https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/generate-story`

## 需要帮助？

查看详细文档：
- `SUPABASE_SETUP.md` - 完整部署说明
- `ENV_SETUP.md` - 环境变量配置说明

