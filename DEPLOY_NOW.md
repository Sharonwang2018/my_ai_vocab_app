# 🚀 立即部署指南

## 已完成的更新

✅ 代码已更新为使用 **OpenRouter API** (DeepSeek 模型)  
✅ 所有密钥已从代码中移除  
✅ 代码已推送到 GitHub

## 部署步骤

### 1. 登录 Supabase CLI

```bash
supabase login
```

这会在浏览器中打开登录页面，完成登录后返回终端。

### 2. 运行部署脚本

```bash
cd /Users/ss/my_ai_vocab_app
./deploy-with-keys.sh
```

这个脚本会自动：
- 链接到你的 Supabase 项目
- 设置环境变量（OpenRouter API key 和 Supabase service role key）
- 部署两个 Edge Functions

### 3. 或者手动部署

如果脚本有问题，可以手动执行：

```bash
# 1. 链接项目
supabase link --project-ref xsqeicialxvfzfzxjorn

# 2. 设置密钥
supabase secrets set OPENROUTER_API_KEY=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
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=sb_secret_pIoDdiE13nNVlnFL5u8MAQ_-70vQ5V3

# 3. 部署函数
supabase functions deploy search-word
supabase functions deploy generate-story
```

## 验证部署

部署成功后，访问应用并测试：

```
http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com
```

尝试搜索一个单词（如 "volcano"），应该可以正常工作了！

## 使用的技术

- **OpenRouter API**: 统一的 LLM 接口
- **DeepSeek 模型**: 通过 OpenRouter 使用
- **Supabase Edge Functions**: 后端函数

## 故障排除

如果遇到问题：

1. **检查登录状态**: `supabase projects list`
2. **查看函数日志**: 在 Supabase Dashboard -> Edge Functions -> Logs
3. **测试函数**: 直接访问函数 URL 测试

