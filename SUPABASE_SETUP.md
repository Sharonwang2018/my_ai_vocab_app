# Supabase Edge Functions 部署说明

## 问题
应用出现错误：`Failed to fetch, uri=https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word`

这是因为 Supabase Edge Functions 还没有部署。

## 解决方案

### 1. 安装 Supabase CLI

```bash
npm install -g supabase
```

### 2. 登录 Supabase

```bash
supabase login
```

### 3. 链接到你的项目

```bash
cd /Users/ss/my_ai_vocab_app
supabase link --project-ref xsqeicialxvfzfzxjorn
```

### 4. 设置环境变量（Secrets）

在 Supabase Dashboard 中设置：
1. 访问：https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions
2. 添加以下 Secrets：
   - `OPENAI_API_KEY`: 你的 OpenAI API 密钥
   - `SUPABASE_SERVICE_ROLE_KEY`: 你的 Supabase Service Role Key（在 Project Settings -> API 中获取）

或者使用 CLI：

```bash
supabase secrets set OPENAI_API_KEY=your_openai_key_here
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_service_role_key_here
```

### 5. 部署 Edge Functions

```bash
# 部署 search-word 函数
supabase functions deploy search-word

# 部署 generate-story 函数
supabase functions deploy generate-story
```

### 6. 验证部署

部署成功后，函数应该可以通过以下 URL 访问：
- `https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word`
- `https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/generate-story`

## 注意事项

1. **OPENAI_API_KEY** 必须在 Supabase Secrets 中配置
2. **SUPABASE_SERVICE_ROLE_KEY** 用于在 Edge Functions 中访问数据库
3. 确保数据库表 `words` 已创建（参考 `supabase/schema.sql`）

## 快速部署命令

```bash
# 1. 登录
supabase login

# 2. 链接项目
supabase link --project-ref xsqeicialxvfzfzxjorn

# 3. 设置密钥（替换为你的实际密钥）
supabase secrets set OPENAI_API_KEY=sk-your-openai-key
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# 4. 部署函数
supabase functions deploy search-word
supabase functions deploy generate-story
```

部署完成后，应用应该可以正常工作了！


