#!/bin/bash

# Supabase Edge Functions 部署脚本
# 使用前请确保：
# 1. 已安装 Supabase CLI: brew install supabase/tap/supabase
# 2. 已登录: supabase login
# 3. 已设置环境变量或在此脚本中配置密钥

echo "🚀 开始部署 Supabase Edge Functions..."
echo ""

# 检查是否已登录
if ! supabase projects list &>/dev/null; then
  echo "❌ 请先登录 Supabase:"
  echo "   supabase login"
  exit 1
fi

# 项目引用 ID
PROJECT_REF="xsqeicialxvfzfzxjorn"

echo "📦 链接到项目: $PROJECT_REF"
supabase link --project-ref $PROJECT_REF

if [ $? -ne 0 ]; then
  echo "❌ 链接项目失败，请检查项目引用 ID"
  exit 1
fi

echo ""
echo "🔑 设置环境变量..."
echo "⚠️  请确保已准备好以下密钥："
echo "   - OPENAI_API_KEY: 你的 OpenAI API 密钥"
echo "   - SUPABASE_SERVICE_ROLE_KEY: 你的 Supabase Service Role Key"
echo ""
read -p "是否继续设置环境变量？(y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  read -p "请输入 OPENAI_API_KEY: " OPENAI_KEY
  read -p "请输入 SUPABASE_SERVICE_ROLE_KEY: " SERVICE_KEY
  
  supabase secrets set OPENAI_API_KEY=$OPENAI_KEY
  supabase secrets set SUPABASE_SERVICE_ROLE_KEY=$SERVICE_KEY
  
  echo "✅ 环境变量已设置"
else
  echo "⏭️  跳过环境变量设置"
  echo "💡 你可以稍后手动设置："
  echo "   supabase secrets set OPENAI_API_KEY=your_key"
  echo "   supabase secrets set SUPABASE_SERVICE_ROLE_KEY=your_key"
fi

echo ""
echo "📤 部署 Edge Functions..."

echo "  部署 search-word..."
supabase functions deploy search-word

if [ $? -eq 0 ]; then
  echo "  ✅ search-word 部署成功"
else
  echo "  ❌ search-word 部署失败"
fi

echo ""
echo "  部署 generate-story..."
supabase functions deploy generate-story

if [ $? -eq 0 ]; then
  echo "  ✅ generate-story 部署成功"
else
  echo "  ❌ generate-story 部署失败"
fi

echo ""
echo "🎉 部署完成！"
echo ""
echo "📝 函数 URL:"
echo "   - https://$PROJECT_REF.supabase.co/functions/v1/search-word"
echo "   - https://$PROJECT_REF.supabase.co/functions/v1/generate-story"
echo ""
echo "💡 如果遇到问题，请查看 SUPABASE_SETUP.md"

