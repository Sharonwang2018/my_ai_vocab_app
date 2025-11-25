# ✅ 验证设置完成

## 已确认的设置

从截图看到：
- ✅ **"Allow anonymous sign-ins"** 已启用（绿色开关）

## 现在请测试

### 步骤 1: 刷新应用
1. 打开应用: http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
2. **强制刷新页面**（清除缓存）:
   - Mac: `Cmd + Shift + R`
   - Windows/Linux: `Ctrl + Shift + R`

### 步骤 2: 测试收藏功能
1. 搜索一个单词（如 "apple"）
2. 点击 heart 图标（❤️）
3. 应该显示 "已加入生词库" 而不是错误

## 如果仍然失败

### 检查 1: 浏览器控制台
1. 按 F12 打开开发者工具
2. 切换到 "Console" 标签
3. 点击 heart 图标
4. 查看错误信息

### 检查 2: 数据库表是否存在
1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/editor
2. 在左侧表列表中查看是否有：
   - ✅ `words` 表
   - ✅ `user_vocab` 表

**如果表不存在：**
在 SQL Editor 中执行 `supabase/schema.sql` 的内容

### 检查 3: RLS 策略
1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/policies
2. 找到 `user_vocab` 表
3. 确保有以下策略：
   - ✅ "Users can view their own vocab" (SELECT)
   - ✅ "Users can insert their own vocab" (INSERT)
   - ✅ "Users can delete their own vocab" (DELETE)

**如果策略不存在：**
在 SQL Editor 中执行：

```sql
-- 确保 user_vocab 表存在
CREATE TABLE IF NOT EXISTS user_vocab (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  word_id UUID NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, word_id)
);

-- 启用 RLS
ALTER TABLE user_vocab ENABLE ROW LEVEL SECURITY;

-- 创建策略
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

## 快速测试命令

在浏览器控制台（F12 -> Console）中运行：

```javascript
// 检查当前用户
console.log('Current user:', supabase.auth.currentUser);

// 尝试匿名登录
supabase.auth.signInAnonymously().then(({ data, error }) => {
  console.log('Login result:', { data, error });
  if (error) {
    console.error('Login error:', error);
  } else {
    console.log('✅ Login successful! User ID:', data.user?.id);
  }
});
```

如果看到 `✅ Login successful!`，说明 Anonymous 认证工作正常。

## 常见错误

### 错误 1: "relation 'user_vocab' does not exist"
**解决**: 执行 `supabase/schema.sql` 创建表

### 错误 2: "permission denied"
**解决**: 检查 RLS 策略是否正确配置

### 错误 3: "Anonymous sign-ins are disabled"
**解决**: 已启用，但可能需要刷新页面或清除缓存


