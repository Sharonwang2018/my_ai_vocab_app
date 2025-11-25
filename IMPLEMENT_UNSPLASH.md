# 🖼️ 切换到 Unsplash API 实现指南

## 为什么切换？

Pollinations.ai 可能不稳定，Unsplash 提供：
- ✅ 非常稳定的服务
- ✅ 高质量真实照片
- ✅ 免费额度充足（50 requests/hour）
- ✅ 无需等待图片生成（即时返回）

## 步骤

### 1. 注册 Unsplash API

1. 访问: https://unsplash.com/developers
2. 点击 "Register as a developer"
3. 创建应用
4. 获取 **Access Key**

### 2. 更新 Edge Function

修改 `supabase/functions/search-word/index.ts`：

```typescript
// 在文件顶部添加
const UNSPLASH_ACCESS_KEY = Deno.env.get('UNSPLASH_ACCESS_KEY')

// 替换图片生成部分
let imageUrl = ''
if (UNSPLASH_ACCESS_KEY) {
  // 使用 Unsplash API
  try {
    const unsplashResponse = await fetch(
      `https://api.unsplash.com/search/photos?query=${encodeURIComponent(targetWord)}&per_page=1&orientation=landscape&client_id=${UNSPLASH_ACCESS_KEY}`
    )
    if (unsplashResponse.ok) {
      const unsplashData = await unsplashResponse.json()
      if (unsplashData.results && unsplashData.results.length > 0) {
        imageUrl = unsplashData.results[0].urls.regular || unsplashData.results[0].urls.small
      }
    }
  } catch (e) {
    console.error('Unsplash API error:', e)
  }
}

// 如果 Unsplash 失败，使用 Pollinations.ai 作为备用
if (!imageUrl) {
  imageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(targetWord)}?width=1024&height=1024`
}
```

### 3. 设置 Supabase Secret

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions
2. 在 **Secrets** 中添加：
   - `UNSPLASH_ACCESS_KEY`: 你的 Unsplash Access Key

### 4. 部署函数

在 Supabase Dashboard 中更新 `search-word` 函数。

## 优势

- ✅ 非常稳定（99.9% 可用性）
- ✅ 即时返回（无需等待生成）
- ✅ 高质量真实照片
- ✅ 免费额度充足

## 注意事项

- 免费额度：50 requests/hour
- 如果超过，会返回错误，可以回退到 Pollinations.ai
- 需要注册和 API key（但完全免费）

