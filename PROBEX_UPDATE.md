# ✅ 已更新为使用 ProbeX API 代理

## 🔄 更新内容

代码已更新为使用 **ProbeX API 代理** (`https://api.probex.top/`) 替代直接调用 DeepSeek API。

### 更新的文件

1. `supabase/functions/search-word/index.ts`
   - API 端点: `https://api.probex.top/v1/chat/completions`

2. `supabase/functions/generate-story/index.ts`
   - API 端点: `https://api.probex.top/v1/chat/completions`

## ✅ 测试结果

测试显示 ProbeX API 代理工作正常：

```json
{
  "definition_zh": "火山是地球表面可以喷发岩浆、火山灰和气体的开口或裂缝",
  "definition_en_simple": "A volcano is an opening in the Earth's surface...",
  "definition_ai_kid": "...",
  "tags": ["nature"],
  "image_url": ""
}
```

## 📤 需要重新部署

由于代码已更新，需要重新部署 Edge Functions：

### 方式 1: 通过 Supabase Dashboard

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions
2. 更新 `search-word` 函数：
   - 复制 `supabase/functions/search-word/index.ts` 的完整内容
   - 粘贴到编辑器
   - 点击 "Deploy"
3. 更新 `generate-story` 函数：
   - 复制 `supabase/functions/generate-story/index.ts` 的完整内容
   - 粘贴到编辑器
   - 点击 "Deploy"

### 方式 2: 使用 CLI

```bash
supabase functions deploy search-word
supabase functions deploy generate-story
```

## ✅ 部署后验证

部署完成后，测试函数：

```bash
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "volcano"}'
```

应该返回包含单词信息和图片 URL 的 JSON 响应。

## 🎯 优势

使用 ProbeX API 代理的好处：
- ✅ 可能提供更好的可用性
- ✅ 可能提供更优惠的价格
- ✅ 统一的 API 接口
- ✅ 与 DeepSeek API 完全兼容

## 📝 当前配置

- **API 端点**: `https://api.probex.top/v1/chat/completions`
- **模型**: `deepseek-chat`
- **API Key**: `sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ`
- **图片生成**: Pollinations.ai (免费)

部署完成后，应用应该可以正常工作了！🎉


