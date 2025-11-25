# 图片生成改进 - 部署指南

## 问题
"hi" 的图片显示不相关（显示建筑而不是问候场景）

## 解决方案
改进了图片生成逻辑，使用 AI 返回的定义提取关键词，并根据词性生成更准确的图片提示。

## 改进内容

1. **扩展停用词列表**
   - 过滤掉更多无意义的词（expression, word, term, means 等）
   - 提取更有意义的关键词

2. **根据词性特殊处理**
   - **interjection/greeting**（如 "hi"）: 生成 `friendly greeting, waving hand, smiling person`
   - **verb**: 添加 "action" 上下文
   - **noun**: 添加 "object" 上下文
   - **adjective**: 添加 "quality" 上下文

3. **提取更多关键词**
   - 从定义中提取前 5 个关键词（之前是 3 个）
   - 更好地反映单词的实际含义

## 部署步骤

### 方法 1: Supabase Dashboard（推荐）

1. 访问 Edge Functions:
   ```
   https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/search-word
   ```

2. 点击 "Edit" 或 "Deploy" 按钮

3. 复制 `/Users/ss/my_ai_vocab_app/supabase/functions/search-word/index.ts` 的完整内容

4. 粘贴到编辑器中

5. 点击 "Deploy" 部署

### 方法 2: 使用 Supabase CLI（如果已配置）

```bash
cd /Users/ss/my_ai_vocab_app
supabase functions deploy search-word
```

## 测试

部署后，测试以下单词：

1. **"hi"** - 应该显示友好的问候场景（挥手、微笑的人）
2. **"apple"** - 应该显示苹果水果
3. **"run"** - 应该显示跑步的动作场景

## 预期效果

- **"hi"**: `friendly greeting, waving hand, smiling person, realistic, high quality, detailed, photograph`
- **"apple"**: `apple, round, fruit, red, green, realistic, high quality, detailed, photograph`
- **"run"**: `run action, realistic, high quality, detailed, photograph`

