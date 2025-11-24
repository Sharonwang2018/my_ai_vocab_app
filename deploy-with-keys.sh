#!/bin/bash

# 使用提供的密钥部署 Supabase Edge Functions

echo "🚀 开始部署 Supabase Edge Functions (使用 OpenRouter + DeepSeek)"
echo ""

# 检查是否已登录
if ! supabase projects list &>/dev/null 2>&1; then
  echo "⚠️  需要先登录 Supabase"
  echo "   运行: supabase login"
  echo "   然后在浏览器中完成登录"
  exit 1
fi

PROJECT_REF="xsqeicialxvfzfzxjorn"
OPENROUTER_KEY="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"
SUPABASE_SERVICE_KEY="sb_secret_pIoDdiE13nNVlnFL5u8MAQ_-70vQ5V3"

echo "📦 链接到项目: $PROJECT_REF"
supabase link --project-ref $PROJECT_REF

if [ $? -ne 0 ]; then
  echo "❌ 链接项目失败"
  exit 1
fi

echo ""
echo "🔑 设置环境变量..."
supabase secrets set OPENROUTER_API_KEY=$OPENROUTER_KEY
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=$SUPABASE_SERVICE_KEY

echo ""
echo "📤 部署 Edge Functions..."

echo "  部署 search-word..."
supabase functions deploy search-word

if [ $? -eq 0 ]; then
  echo "  ✅ search-word 部署成功"
else
  echo "  ❌ search-word 部署失败"
  exit 1
fi

echo ""
echo "  部署 generate-story..."
supabase functions deploy generate-story

if [ $? -eq 0 ]; then
  echo "  ✅ generate-story 部署成功"
else
  echo "  ❌ generate-story 部署失败"
  exit 1
fi

echo ""
echo "🎉 部署完成！"
echo ""
echo "📝 函数 URL:"
echo "   - https://$PROJECT_REF.supabase.co/functions/v1/search-word"
echo "   - https://$PROJECT_REF.supabase.co/functions/v1/generate-story"
echo ""
echo "✅ 现在可以测试应用了！"
echo "   访问: http://my-ai-vocab-app-deploy.s3-website-us-east-1.amazonaws.com"

