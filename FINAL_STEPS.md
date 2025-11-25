# ✅ 最后步骤 - 完成设置

## 当前状态

从截图确认：
- ✅ **"Allow anonymous sign-ins"** 已启用（绿色开关）
- ✅ 应用已显示单词定义和图片

## 现在需要做的

### 步骤 1: 保存设置（重要！）

在 Supabase Dashboard 中：
1. **点击 "Save" 按钮**（在 Anonymous 设置面板的右下角）
2. 等待看到 "Saved" 或成功提示
3. 关闭设置面板

### 步骤 2: 刷新应用

1. 切换到应用页面: http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
2. **强制刷新页面**（清除缓存）:
   - Mac: `Cmd + Shift + R`
   - Windows/Linux: `Ctrl + Shift + R`

### 步骤 3: 测试收藏功能

1. 搜索一个单词（如 "apple"）
2. 点击 heart 图标（❤️）
3. 应该显示 "已加入生词库" 而不是错误

## 如果仍然失败

### 检查 1: 数据库表是否存在

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/editor
2. 在左侧表列表中查看是否有：
   - ✅ `words` 表
   - ✅ `user_vocab` 表

**如果 `user_vocab` 表不存在：**

在 SQL Editor 中执行以下 SQL：

```sql
-- 创建 user_vocab 表
CREATE TABLE IF NOT EXISTS user_vocab (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  word_id UUID NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, word_id)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_vocab_user_id ON user_vocab(user_id);
CREATE INDEX IF NOT EXISTS idx_user_vocab_word_id ON user_vocab(word_id);
CREATE INDEX IF NOT EXISTS idx_user_vocab_created_at ON user_vocab(created_at);

-- 启用 RLS
ALTER TABLE user_vocab ENABLE ROW LEVEL SECURITY;

-- 创建策略
DROP POLICY IF EXISTS "Users can view their own vocab" ON user_vocab;
CREATE POLICY "Users can view their own vocab"
  ON user_vocab FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own vocab" ON user_vocab;
CREATE POLICY "Users can insert their own vocab"
  ON user_vocab FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own vocab" ON user_vocab;
CREATE POLICY "Users can delete their own vocab"
  ON user_vocab FOR DELETE
  USING (auth.uid() = user_id);
```

### 检查 2: 浏览器控制台

1. 按 F12 打开开发者工具
2. 切换到 "Console" 标签
3. 点击 heart 图标
4. 查看错误信息

**常见错误：**
- `relation "user_vocab" does not exist` → 需要执行上面的 SQL
- `permission denied` → RLS 策略问题，需要检查策略
- `Anonymous sign-ins are disabled` → 需要刷新页面或重新保存设置

## 验证清单

- [ ] 已点击 "Save" 保存 Anonymous 设置
- [ ] 已强制刷新应用页面
- [ ] `user_vocab` 表已创建
- [ ] RLS 策略已配置
- [ ] 已测试收藏功能

## 成功标志

当一切正常时：
- ✅ 点击 heart 图标后，显示 "已加入生词库"
- ✅ heart 图标变成红色（实心）
- ✅ 再次点击可以取消收藏
- ✅ 浏览器控制台没有错误


