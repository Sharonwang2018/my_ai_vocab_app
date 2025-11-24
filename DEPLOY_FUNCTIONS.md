# 🚀 部署 Edge Functions - 最终步骤

## ✅ Secrets 已设置完成

从你的 Dashboard 可以看到，以下 Secrets 已成功配置：
- ✅ `DEEPSEEK_API_KEY`
- ✅ `SERVICE_ROLE_KEY`

## 📤 现在需要部署 Edge Functions

有两种方式部署：

### 方式 1: 通过 Supabase Dashboard（推荐）

1. **访问 Edge Functions 页面**:
   ```
   https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions
   ```

2. **部署 search-word 函数**:
   - 点击 "Create a new function" 或选择现有函数
   - 函数名称: `search-word`
   - 复制 `supabase/functions/search-word/index.ts` 的完整内容
   - 粘贴到代码编辑器中
   - 点击 "Deploy"

3. **部署 generate-story 函数**:
   - 重复步骤 2
   - 函数名称: `generate-story`
   - 复制 `supabase/functions/generate-story/index.ts` 的完整内容
   - 粘贴到代码编辑器中
   - 点击 "Deploy"

### 方式 2: 使用 Supabase CLI

```bash
# 1. 登录（如果还没登录）
supabase login

# 2. 链接项目
cd /Users/ss/my_ai_vocab_app
supabase link --project-ref xsqeicialxvfzfzxjorn

# 3. 部署函数
supabase functions deploy search-word
supabase functions deploy generate-story
```

## ✅ 验证部署

部署成功后，测试函数：

```bash
# 测试 search-word
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "volcano"}'
```

如果返回单词信息和图片 URL，说明部署成功！

## 🎯 部署后的功能

- ✅ 单词搜索：使用 DeepSeek API 生成定义
- ✅ 图片生成：使用免费的 Pollinations.ai 生成卡通图片
- ✅ 故事生成：使用 DeepSeek API 从收藏的单词生成故事

## 📝 函数 URL

部署后，函数可通过以下 URL 访问：
- `https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word`
- `https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/generate-story`

部署完成后，应用就可以正常工作了！🎉

