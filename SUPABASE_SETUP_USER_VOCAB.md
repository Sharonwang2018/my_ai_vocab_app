# Supabase user_vocab 表设置指南

## 问题
如果点击收藏按钮出现 "无法保存，请检查网络连接" 错误，可能是 `user_vocab` 表不存在或权限配置不正确。

## 解决方案

### 1. 创建 user_vocab 表

在 Supabase SQL Editor 中运行以下 SQL：

```sql
-- 创建 user_vocab 表
CREATE TABLE IF NOT EXISTS user_vocab (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  word_id UUID NOT NULL REFERENCES words(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, word_id)
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_user_vocab_user_id ON user_vocab(user_id);
CREATE INDEX IF NOT EXISTS idx_user_vocab_word_id ON user_vocab(word_id);

-- 启用 Row Level Security (RLS)
ALTER TABLE user_vocab ENABLE ROW LEVEL SECURITY;

-- 创建 RLS 策略：允许用户查看自己的收藏
CREATE POLICY "Users can view their own vocab"
  ON user_vocab FOR SELECT
  USING (auth.uid() = user_id);

-- 创建 RLS 策略：允许用户添加自己的收藏
CREATE POLICY "Users can insert their own vocab"
  ON user_vocab FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 创建 RLS 策略：允许用户删除自己的收藏
CREATE POLICY "Users can delete their own vocab"
  ON user_vocab FOR DELETE
  USING (auth.uid() = user_id);
```

### 2. 确保 Anonymous 认证已启用

1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers
2. 找到 "Anonymous" 提供商
3. 确保它已启用

### 3. 验证表结构

运行以下查询验证表是否存在：

```sql
SELECT * FROM user_vocab LIMIT 1;
```

### 4. 测试权限

确保匿名用户可以插入数据：

```sql
-- 检查 RLS 策略
SELECT * FROM pg_policies WHERE tablename = 'user_vocab';
```

## 表结构说明

- `id`: 主键，自动生成
- `user_id`: 用户ID（来自 auth.users）
- `word_id`: 单词ID（来自 words 表）
- `created_at`: 创建时间
- `UNIQUE(user_id, word_id)`: 确保每个用户每个单词只收藏一次

## 如果仍然有问题

1. 检查浏览器控制台的错误信息
2. 检查 Supabase Dashboard -> Logs 中的错误
3. 确认 `words` 表存在且 `word_id` 有效

