-- ============================================
-- Supabase 数据库表结构（安全版本 - 可重复执行）
-- ============================================

-- 1. 创建 words 表（单词表）
CREATE TABLE IF NOT EXISTS words (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  word TEXT NOT NULL UNIQUE,
  content JSONB NOT NULL DEFAULT '{}',
  assets JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_words_word ON words(word);
CREATE INDEX IF NOT EXISTS idx_words_created_at ON words(created_at);

-- 启用 Row Level Security (RLS)
ALTER TABLE words ENABLE ROW LEVEL SECURITY;

-- RLS 策略：允许所有人查看单词（只读）
DROP POLICY IF EXISTS "Anyone can view words" ON words;
CREATE POLICY "Anyone can view words"
  ON words FOR SELECT
  USING (true);

-- ============================================

-- 2. 创建 user_vocab 表（用户生词本）
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
CREATE INDEX IF NOT EXISTS idx_user_vocab_created_at ON user_vocab(created_at);

-- 启用 Row Level Security (RLS)
ALTER TABLE user_vocab ENABLE ROW LEVEL SECURITY;

-- RLS 策略：允许用户查看自己的收藏
DROP POLICY IF EXISTS "Users can view their own vocab" ON user_vocab;
CREATE POLICY "Users can view their own vocab"
  ON user_vocab FOR SELECT
  USING (auth.uid() = user_id);

-- RLS 策略：允许用户添加自己的收藏
DROP POLICY IF EXISTS "Users can insert their own vocab" ON user_vocab;
CREATE POLICY "Users can insert their own vocab"
  ON user_vocab FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS 策略：允许用户删除自己的收藏
DROP POLICY IF EXISTS "Users can delete their own vocab" ON user_vocab;
CREATE POLICY "Users can delete their own vocab"
  ON user_vocab FOR DELETE
  USING (auth.uid() = user_id);


