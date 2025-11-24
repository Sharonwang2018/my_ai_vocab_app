# API Key 和模型检查

## ✅ 模型名称

代码中使用的模型名称是 **`deepseek-chat`**，这是正确的。

根据 DeepSeek 官方文档：
- ✅ `deepseek-chat` - 聊天模型（我们使用的）
- `deepseek-reasoner` - 推理模型
- `deepseek-coder` - 代码模型

## ❌ API Key 问题

测试显示 API key 认证失败：
```
Authentication Fails, Your api key: ****dlAJ is invalid
```

## 🔍 可能的原因

1. **API Key 有空格**
   - 从图片看，key 可能有空格：`sk-7XpwEb0Wql59BrrScy WkkxRLD2s5CunbyuofnQP Ez6IDdLAJ`
   - 需要确保在 Supabase Secrets 中设置时**没有空格**

2. **API Key 无效或过期**
   - 需要确认 key 是否有效
   - 检查 DeepSeek 账户状态

3. **Supabase Secrets 中的 key 不正确**
   - 检查 Dashboard 中的 `DEEPSEEK_API_KEY` 是否正确
   - 确保没有多余的空格或换行

## 🔧 解决方案

### 1. 检查 Supabase Secrets

访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions

检查 `DEEPSEEK_API_KEY` 的值：
- 应该是: `sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ`
- **确保没有空格**
- **确保完整复制**

### 2. 验证 API Key

在终端测试：

```bash
curl -X POST https://api.deepseek.com/v1/chat/completions \
  -H "Authorization: Bearer sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ" \
  -H "Content-Type: application/json" \
  -d '{"model": "deepseek-chat", "messages": [{"role": "user", "content": "test"}], "max_tokens": 10}'
```

如果返回错误，说明 key 无效。

### 3. 获取新的 API Key

如果 key 无效：
1. 访问 DeepSeek 控制台
2. 生成新的 API key
3. 更新 Supabase Secrets 中的 `DEEPSEEK_API_KEY`

## 📝 当前状态

- ✅ 模型名称正确: `deepseek-chat`
- ❌ API Key 认证失败
- ✅ 代码逻辑正确

## 🎯 下一步

1. 检查 Supabase Secrets 中的 API key 是否正确（无空格）
2. 如果 key 无效，获取新的 DeepSeek API key
3. 更新 Secrets 后重新测试

