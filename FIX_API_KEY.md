# 🔧 修复 API Key 问题

## ❌ 当前问题

测试结果显示 DeepSeek API key **无效**：

```
Authentication Fails, Your api key: ****dlAJ is invalid
```

## ✅ 已验证正确的部分

- ✅ 模型名称: `deepseek-chat` (正确)
- ✅ API 端点: `https://api.deepseek.com/v1/chat/completions` (正确)
- ✅ 代码逻辑: 完全正确
- ✅ 请求格式: 符合 DeepSeek API 规范

## 🔍 问题原因

API key `sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ` 被 DeepSeek API 拒绝，可能原因：

1. **Key 已过期或被撤销**
2. **Key 格式不正确**
3. **账户状态问题**（未激活、余额不足等）
4. **Key 属于其他服务**（不是 DeepSeek 的 key）

## 🔧 解决步骤

### 1. 获取新的 DeepSeek API Key

访问 DeepSeek 控制台：
- https://platform.deepseek.com/ 或
- https://www.deepseek.com/

步骤：
1. 登录你的 DeepSeek 账户
2. 进入 API Keys 或 Settings 页面
3. 创建新的 API key
4. 复制新的 key（确保完整，无空格）

### 2. 更新 Supabase Secrets

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions
2. 点击 "Secrets" 标签
3. 找到 `DEEPSEEK_API_KEY`
4. 更新为新的有效 key
5. 点击 "Save"

### 3. 验证新 Key

运行测试脚本：

```bash
cd /Users/ss/my_ai_vocab_app
node test-deepseek-direct.js
```

如果看到 "✅ DeepSeek API 工作正常!"，说明 key 有效。

### 4. 重新部署函数

更新 Secrets 后，函数会自动使用新的 key。或者重新部署：

```bash
# 如果使用 CLI
supabase functions deploy search-word
supabase functions deploy generate-story
```

## 📝 测试脚本

已创建测试脚本：
- `test-deepseek-direct.js` - 直接测试 DeepSeek API
- `test-deepseek-function.ts` - 测试完整函数逻辑

运行测试：
```bash
node test-deepseek-direct.js
```

## ✅ 完成后

一旦获得有效的 API key 并更新到 Supabase Secrets，应用应该可以正常工作了！

测试应用：
```
http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
```


