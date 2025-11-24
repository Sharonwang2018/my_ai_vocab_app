# 🚀 最终部署指南 - 使用 DeepSeek + 免费图片生成

## ✅ 已完成的更新

1. **API 切换**: 从 OpenRouter 切换到直接使用 DeepSeek API
2. **图片生成**: 使用免费的 Pollinations.ai API（无需 key）
3. **代码优化**: 所有密钥已从代码中移除

## 🔑 需要配置的密钥

### 在 Supabase Dashboard 中设置：

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions
2. 在 **Secrets** 中添加：
   - `DEEPSEEK_API_KEY`: `sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ`
   - `SUPABASE_SERVICE_ROLE_KEY`: `sb_secret_pIoDdiE13nNVlnFL5u8MAQ_-70vQ5V3`

## 📝 技术栈

- **文本生成**: DeepSeek API (`deepseek-chat` 模型)
- **图片生成**: Pollinations.ai (免费，无需 key)
- **后端**: Supabase Edge Functions
- **前端**: Flutter Web

## 🎨 图片生成说明

代码现在使用 Pollinations.ai 免费 API 生成图片：

```typescript
const imageUrl = `https://image.pollinations.ai/prompt/${targetWord}%20cartoon%20cute?width=1024&height=1024`
```

特点：
- ✅ 完全免费，无需 API key
- ✅ 自动为每个单词生成卡通风格的图片
- ✅ 关键词使用英文（单词 + "cartoon cute"）

## 🚀 部署步骤

### 方式 1: 使用 CLI（推荐）

```bash
# 1. 登录 Supabase
supabase login

# 2. 运行部署脚本
cd /Users/ss/my_ai_vocab_app
./deploy-with-keys.sh
```

### 方式 2: 通过 Dashboard

1. **设置 Secrets**:
   - Dashboard -> Edge Functions -> Secrets
   - 添加 `DEEPSEEK_API_KEY` 和 `SUPABASE_SERVICE_ROLE_KEY`

2. **部署函数**:
   - Dashboard -> Edge Functions
   - 创建/更新 `search-word` 函数
   - 复制 `supabase/functions/search-word/index.ts` 的内容
   - 创建/更新 `generate-story` 函数
   - 复制 `supabase/functions/generate-story/index.ts` 的内容

## ✅ 验证部署

部署后测试：

```bash
# 测试 search-word
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "volcano"}'
```

应该返回包含图片 URL 的单词信息。

## 💰 成本

- **文本生成**: DeepSeek API（根据使用量计费）
- **图片生成**: 完全免费（Pollinations.ai）
- **数据库**: Supabase 免费额度

## 🎯 功能

1. **单词搜索**: 使用 DeepSeek 生成单词定义和解释
2. **图片生成**: 自动为每个单词生成卡通图片
3. **故事生成**: 使用 DeepSeek 从收藏的单词生成故事

部署完成后，应用应该可以完全正常工作了！

