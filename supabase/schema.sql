-- ============================================
-- Supabase 数据库表结构
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
CREATE POLICY "Anyone can view words"
  ON words FOR SELECT
  USING (true);

-- RLS 策略：只允许服务角色插入/更新单词（通过 Edge Functions）
-- 注意：这个策略允许通过 service_role_key 插入，普通用户不能直接插入

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
CREATE POLICY "Users can view their own vocab"
  ON user_vocab FOR SELECT
  USING (auth.uid() = user_id);

-- RLS 策略：允许用户添加自己的收藏
CREATE POLICY "Users can insert their own vocab"
  ON user_vocab FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS 策略：允许用户删除自己的收藏
CREATE POLICY "Users can delete their own vocab"
  ON user_vocab FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 表结构说明
-- ============================================

-- words 表字段：
--   - id: UUID 主键
--   - word: 单词文本（唯一）
--   - content: JSONB 包含定义、词性、音标等
--     {
--       "definition_zh": "中文定义",
--       "definition_en_simple": "英文定义",
--       "definition_ai_kid": "儿童友好解释",
--       "part_of_speech": "词性",
--       "phonetic_us": "美式音标",
--       "phonetic_uk": "英式音标",
--       "tags": ["标签1", "标签2"]
--     }
--   - assets: JSONB 包含图片等资源
--     {
--       "image_url": "图片URL"
--     }
--   - created_at: 创建时间
--   - updated_at: 更新时间

-- user_vocab 表字段：
--   - id: UUID 主键
--   - user_id: 用户ID（外键到 auth.users）
--   - word_id: 单词ID（外键到 words）
--   - created_at: 收藏时间
--   - UNIQUE(user_id, word_id): 确保每个用户每个单词只收藏一次

