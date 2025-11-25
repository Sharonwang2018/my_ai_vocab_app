# 通过 Supabase Dashboard 部署指南

由于 CLI 需要交互式登录，你可以通过 Supabase Dashboard 直接配置和部署。

## 方法 1: 通过 Dashboard 设置 Secrets（推荐）

### 步骤 1: 设置环境变量

1. 访问 Supabase Dashboard: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn
2. 在左侧导航栏，点击 **"Edge Functions"**（在 CONFIGURATION 下）
3. 点击 **"Secrets"** 标签
4. 添加以下环境变量：
   - **OPENROUTER_API_KEY**: `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`
   - **SUPABASE_SERVICE_ROLE_KEY**: `sb_secret_pIoDdiE13nNVlnFL5u8MAQ_-70vQ5V3`

### 步骤 2: 部署函数

#### 选项 A: 使用 Supabase CLI（需要先登录）

```bash
# 1. 在终端运行（会打开浏览器登录）
supabase login

# 2. 链接项目
supabase link --project-ref xsqeicialxvfzfzxjorn

# 3. 部署函数
supabase functions deploy search-word
supabase functions deploy generate-story
```

#### 选项 B: 通过 Dashboard 上传

1. 在 Dashboard -> Edge Functions 中
2. 点击 "Create a new function" 或选择现有函数
3. 复制 `supabase/functions/search-word/index.ts` 的内容
4. 粘贴到编辑器中
5. 点击 "Deploy"
6. 重复步骤 3-5 部署 `generate-story`

## 方法 2: 使用 Supabase Management API

如果你有 Supabase Access Token，可以使用 API 直接部署：

```bash
# 设置访问令牌
export SUPABASE_ACCESS_TOKEN=your_access_token

# 部署函数
supabase functions deploy search-word
supabase functions deploy generate-story
```

## 验证部署

部署成功后，测试函数：

```bash
# 测试 search-word
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "volcano"}'

# 测试 generate-story
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/generate-story \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"wordIds": ["test-id"], "theme": "adventure"}'
```

## 获取 Supabase Access Token

1. 访问: https://supabase.com/dashboard/account/tokens
2. 创建新的 Access Token
3. 复制令牌
4. 在终端设置: `export SUPABASE_ACCESS_TOKEN=your_token`

## 快速检查清单

- [ ] Secrets 已在 Dashboard 中设置
- [ ] 函数代码已更新（使用 OpenRouter）
- [ ] 函数已部署
- [ ] 测试函数调用成功
- [ ] 应用可以正常搜索单词


