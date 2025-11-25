# 🔗 测试链接集合

## 🌐 前端应用

**主应用地址（已部署）：**
```
http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
```

## 🔧 Supabase Dashboard 链接

### Authentication（认证）
- **Anonymous 设置**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers
- **用户管理**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/users

### Database（数据库）
- **SQL Editor**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/sql/new
- **表编辑器**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/editor
- **RLS 策略**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/policies

### Edge Functions（边缘函数）
- **Functions 列表**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions
- **search-word 函数**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/search-word
- **generate-story 函数**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions/generate-story
- **Secrets 配置**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/settings/functions

### Logs（日志）
- **Edge Functions 日志**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/logs/edge-logs
- **API 日志**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/logs/api-logs

## 🧪 测试步骤

### 1. 测试前端应用
1. 打开: http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
2. **强制刷新页面**（清除缓存）:
   - Mac: `Cmd + Shift + R`
   - Windows/Linux: `Ctrl + Shift + R`
3. 搜索单词（如 "apple"）
4. 检查是否显示：
   - ✅ 单词定义（中英文）
   - ✅ 音标和发音按钮
   - ✅ 词性
   - ✅ AI 生成的图片
   - ✅ 记忆小贴士

### 2. 测试收藏功能
1. 搜索一个单词（如 "apple"）
2. 点击 heart 图标（❤️）
3. 应该显示 "已加入生词库" 而不是错误
4. heart 图标应该变成红色（实心）

### 3. 测试 Edge Functions
使用 curl 测试：

```bash
# 测试 search-word
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/search-word \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "apple"}'

# 测试 generate-story
curl -X POST https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1/generate-story \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"wordIds": ["word-id-1", "word-id-2"], "theme": "adventure"}'
```

## 📝 快速检查清单

### 前端应用
- [ ] 应用可以正常打开
- [ ] 可以搜索单词
- [ ] 显示单词定义和图片
- [ ] 收藏功能正常工作

### Supabase 配置
- [ ] Anonymous 认证已启用
- [ ] `words` 表已创建
- [ ] `user_vocab` 表已创建
- [ ] RLS 策略已配置
- [ ] Edge Functions 已部署
- [ ] Secrets 已配置（DEEPSEEK_API_KEY, SERVICE_ROLE_KEY）

## 🐛 故障排除

### 如果应用无法打开
- 检查 S3 bucket 是否公开
- 检查 CloudFront 配置（如果使用）

### 如果收藏功能失败
1. 检查 Anonymous 认证是否启用
2. 检查 `user_vocab` 表是否存在
3. 检查 RLS 策略是否正确
4. 查看浏览器控制台错误（F12）

### 如果图片不显示
1. 检查 Pollinations.ai 服务是否正常
2. 查看浏览器控制台网络请求
3. 检查 Edge Function 日志

## 📚 相关文档

- 项目 README: `README.md`
- 部署指南: `DEPLOYMENT.md`
- 故障排除: `TROUBLESHOOTING_FAVORITE.md`
- 启用 Anonymous: `ENABLE_ANONYMOUS_STEP_BY_STEP.md`


