# 🔧 快速修复指南

## 问题 1: 图片不显示

### 原因
图片 URL 已生成，但可能格式过于复杂导致 Pollinations.ai 无法处理。

### 解决方案
已在代码中简化图片提示词格式。需要重新部署 Edge Function。

## 问题 2: 无法收藏（点击 heart 报错）

### 原因
错误信息 "无法登录,请检查网络连接或刷新页面重试" 通常表示：
1. **数据库表未创建** - `user_vocab` 表不存在
2. **Anonymous 认证未启用** - 虽然你说已启用，但可能配置有问题

### 解决方案

#### 步骤 1: 创建数据库表（必须）

在 Supabase SQL Editor 中执行以下 SQL：

```sql
-- 1. 创建 words 表
CREATE TABLE IF NOT EXISTS words (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  word TEXT NOT NULL UNIQUE,
  content JSONB NOT NULL DEFAULT '{}',
  assets JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_words_word ON words(word);
ALTER TABLE words ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view words" ON words FOR SELECT USING (true);

-- 2. 创建 user_vocab 表
CREATE TABLE IF NOT EXISTS user_vocab (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  word_id UUID NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, word_id)
);

CREATE INDEX IF NOT EXISTS idx_user_vocab_user_id ON user_vocab(user_id);
CREATE INDEX IF NOT EXISTS idx_user_vocab_word_id ON user_vocab(word_id);
ALTER TABLE user_vocab ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own vocab" ON user_vocab FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own vocab" ON user_vocab FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete their own vocab" ON user_vocab FOR DELETE USING (auth.uid() = user_id);
```

#### 步骤 2: 验证 Anonymous 认证

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers
2. 找到 "Anonymous" 提供商
3. **确保它已启用**（开关应该是绿色的）
4. 如果已启用但还是失败，尝试：
   - 禁用 Anonymous
   - 保存
   - 重新启用 Anonymous
   - 保存

#### 步骤 3: 更新 Edge Function

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/search-word
2. 复制 `/Users/ss/my_ai_vocab_app/supabase/functions/search-word/index.ts` 的完整内容
3. 粘贴并部署

## 验证

### 测试图片
搜索 "apple"，应该能看到图片。

### 测试收藏
1. 搜索任意单词
2. 点击 heart 图标
3. 应该显示 "已加入生词库" 而不是错误

## 如果仍然失败

检查浏览器控制台（F12）的错误信息，告诉我具体的错误内容。

