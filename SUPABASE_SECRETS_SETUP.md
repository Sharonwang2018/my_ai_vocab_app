# Supabase Edge Functions Secrets 设置指南

## ⚠️ 重要提示

Supabase **不允许** Secrets 名称以 `SUPABASE_` 开头！

如果你看到错误："Name must not start with the SUPABASE_ prefix"，请使用下面的正确名称。

## ✅ 需要设置的 Secrets

在 Supabase Dashboard -> Edge Functions -> Secrets 中添加：

### 1. DEEPSEEK_API_KEY
- **名称**: `DEEPSEEK_API_KEY`
- **值**: `sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ`

### 2. SERVICE_ROLE_KEY
- **名称**: `SERVICE_ROLE_KEY` ⚠️ **不要使用 `SUPABASE_SERVICE_ROLE_KEY`**
- **值**: `sb_secret_pIoDdiE13nNVlnFL5u8MAQ_-70vQ5V3`

## 📝 设置步骤

1. 访问 Supabase Dashboard:
   ```
   https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions
   ```

2. 点击 "Secrets" 标签

3. 在 "ADD OR REPLACE SECRETS" 部分：
   - **第一个 Secret**:
     - Name: `DEEPSEEK_API_KEY`
     - Value: `sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ`
   
   - **第二个 Secret**:
     - Name: `SERVICE_ROLE_KEY` ⚠️ **注意：不是 `SUPABASE_SERVICE_ROLE_KEY`**
     - Value: `sb_secret_pIoDdiE13nNVlnFL5u8MAQ_-70vQ5V3`

4. 点击 "Save" 保存

## 🔍 验证

设置完成后，你应该能在 "Existing secrets" 列表中看到：
- `DEEPSEEK_API_KEY`
- `SERVICE_ROLE_KEY`

## ❌ 常见错误

**错误**: "Name must not start with the SUPABASE_ prefix"

**原因**: Supabase 保留 `SUPABASE_` 前缀，不允许用户使用

**解决**: 使用 `SERVICE_ROLE_KEY` 而不是 `SUPABASE_SERVICE_ROLE_KEY`

## 💡 代码中的使用

代码已经更新为使用 `SERVICE_ROLE_KEY`：

```typescript
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY')
```

所以只需要在 Dashboard 中设置 `SERVICE_ROLE_KEY` 即可。

## ✅ 完成

设置完这两个 Secrets 后，就可以部署 Edge Functions 了！


