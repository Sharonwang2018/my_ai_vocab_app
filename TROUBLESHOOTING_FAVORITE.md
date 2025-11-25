# 🔧 收藏功能故障排除

## 错误信息
"操作失败: Exception: 无法登录。请确保：1) 网络连接正常 2) Supabase Anonymous 认证已启用 3) 刷新页面重试"

## 可能的原因和解决方案

### 1. Anonymous 认证未正确启用

**检查步骤：**
1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers
2. 找到 "Anonymous" 提供商
3. **确保开关是绿色的（已启用）**

**如果已启用但还是失败：**
- 尝试禁用 Anonymous
- 保存
- 重新启用 Anonymous
- 保存
- 刷新应用页面

### 2. 数据库表未创建

**检查步骤：**
1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/editor
2. 在左侧表列表中查看是否有 `user_vocab` 表

**如果表不存在：**
在 SQL Editor 中执行 `supabase/schema.sql` 中的 SQL

### 3. RLS 策略问题

**检查步骤：**
1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/policies
2. 找到 `user_vocab` 表的策略
3. 确保有以下策略：
   - "Users can view their own vocab" (SELECT)
   - "Users can insert their own vocab" (INSERT)
   - "Users can delete their own vocab" (DELETE)

**如果策略不存在：**
在 SQL Editor 中执行：

```sql
CREATE POLICY "Users can view their own vocab"
  ON user_vocab FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own vocab"
  ON user_vocab FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own vocab"
  ON user_vocab FOR DELETE
  USING (auth.uid() = user_id);
```

### 4. 检查浏览器控制台

1. 打开应用
2. 按 F12 打开开发者工具
3. 切换到 "Console" 标签
4. 点击 heart 图标
5. 查看控制台中的错误信息

**常见错误：**
- `relation "user_vocab" does not exist` → 表未创建
- `permission denied` → RLS 策略问题
- `Anonymous sign-ins are disabled` → Anonymous 认证未启用

### 5. 测试匿名登录

在浏览器控制台中运行：

```javascript
// 检查当前用户
console.log('Current user:', supabase.auth.currentUser);

// 尝试匿名登录
supabase.auth.signInAnonymously().then(({ data, error }) => {
  console.log('Login result:', { data, error });
});
```

## 快速检查清单

- [ ] Anonymous 认证已启用
- [ ] `user_vocab` 表已创建
- [ ] RLS 策略已配置
- [ ] 网络连接正常
- [ ] 已刷新页面

## 如果仍然失败

请提供：
1. 浏览器控制台的完整错误信息
2. Supabase Dashboard -> Logs 中的错误
3. 具体的错误消息


