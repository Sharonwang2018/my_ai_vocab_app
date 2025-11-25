# 快速部署步骤

## 部署 Edge Function: search-word

### 步骤 1: 访问 Supabase Dashboard
```
https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/search-word
```

### 步骤 2: 复制代码
复制以下文件的完整内容：
```
/Users/ss/my_ai_vocab_app/supabase/functions/search-word/index.ts
```

### 步骤 3: 粘贴并部署
1. 在 Dashboard 中点击 "Edit" 或 "Deploy" 按钮
2. 粘贴代码
3. 点击 "Deploy" 按钮
4. 等待部署完成（通常几秒钟）

### 步骤 4: 测试
部署完成后，测试链接：
- **生产环境**: http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
- **本地测试**: http://localhost:8080

### 测试建议
1. 搜索 "hello" 或 "hey"（新单词，测试问候语图片）
2. 或者删除数据库中 "hi" 的记录后重新搜索
3. 应该看到友好的问候场景图片（挥手、微笑的人）

## 改进内容
- ✅ 直接检测问候语单词（hi, hello, hey 等）
- ✅ 优先处理问候语，生成相关图片
- ✅ 更明确的图片提示词
- ✅ 扩展停用词列表

