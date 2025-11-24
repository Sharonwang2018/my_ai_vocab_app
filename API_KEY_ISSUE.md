# OpenRouter API Key 问题诊断

## ❌ 当前状态

API Key 测试返回 **401 错误: "User not found"**

这意味着 API Key 无法验证，可能的原因：

1. **API Key 未激活**
   - 新创建的 API Key 可能需要一些时间激活
   - 检查 OpenRouter Dashboard 中的 key 状态

2. **账户问题**
   - OpenRouter 账户可能未完全设置
   - 可能需要验证邮箱或完成账户设置

3. **API Key 格式问题**
   - 确认 key 完整复制（没有多余空格）
   - 确认 key 格式正确：`sk-or-v1-...`

4. **账户余额**
   - 虽然 401 通常不是余额问题，但检查账户是否有余额

## 🔍 诊断步骤

### 1. 检查 OpenRouter Dashboard

访问: https://openrouter.ai/keys

检查：
- API Key 是否显示为 "Active"
- 是否有任何警告或错误信息
- Key 的创建时间和最后使用时间

### 2. 验证 API Key

在 OpenRouter Dashboard 中：
- 查看 API Key 列表
- 确认 key 状态
- 如果无效，创建新的 key

### 3. 测试 API Key

可以使用以下命令测试：

```bash
curl https://openrouter.ai/api/v1/auth/key \
  -H "Authorization: Bearer YOUR_API_KEY"
```

如果返回账户信息，说明 key 有效。

## 🔧 解决方案

### 选项 1: 使用新的 API Key

1. 访问 OpenRouter Dashboard: https://openrouter.ai/keys
2. 创建新的 API Key
3. 复制新的 key
4. 更新 Supabase Secrets 中的 `OPENROUTER_API_KEY`

### 选项 2: 检查账户设置

1. 确认 OpenRouter 账户已完全设置
2. 验证邮箱（如果要求）
3. 检查账户状态

### 选项 3: 临时使用其他模型

如果 OpenRouter 有问题，可以：
- 使用 OpenAI API（如果有 key）
- 使用其他 LLM 提供商
- 或者等待 OpenRouter key 激活

## 📝 更新代码

一旦获得有效的 API Key，更新 Supabase Secrets：

```bash
# 在 Supabase Dashboard 中
# Edge Functions -> Secrets -> 更新 OPENROUTER_API_KEY
```

或者使用 CLI：

```bash
supabase secrets set OPENROUTER_API_KEY=your_new_key
```

## ✅ 验证修复

部署后，测试函数：

```bash
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "test"}'
```

如果返回单词信息而不是错误，说明修复成功。

## 💡 建议

1. **先检查 OpenRouter Dashboard** - 确认 key 状态
2. **如果 key 无效，创建新的** - 在 Dashboard 中生成新 key
3. **更新 Supabase Secrets** - 使用新的有效 key
4. **重新部署函数** - 确保使用新的 key

