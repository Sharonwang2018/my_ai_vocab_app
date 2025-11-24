#!/bin/bash

# 测试部署的函数

ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzcWVpY2lhbHh2Znpmenhqb3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3ODA2ODIsImV4cCI6MjA3OTM1NjY4Mn0.hIOzK-O1yohy1bGsOIK0p3ttJMePfS9NHzVs1GE2-Xg"
BASE_URL="https://xsqeicialxvfzfzxjorn.supabase.co/functions/v1"

echo "🧪 测试 Edge Functions 部署..."
echo ""

echo "1️⃣ 测试 search-word 函数..."
RESPONSE=$(curl -s -X POST "$BASE_URL/search-word" \
  -H "Authorization: Bearer $ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{"word": "volcano"}')

if echo "$RESPONSE" | grep -q "error"; then
  echo "❌ search-word 函数错误:"
  echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
else
  echo "✅ search-word 函数工作正常!"
  echo "$RESPONSE" | python3 -c "import sys, json; d=json.load(sys.stdin); print(f\"单词: {d.get('word', 'N/A')}\"); print(f\"定义: {d.get('content', {}).get('definition_zh', 'N/A')[:50]}...\")" 2>/dev/null || echo "响应已收到"
fi

echo ""
echo "2️⃣ 检查函数是否已部署..."
echo "访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/functions"
echo ""
echo "如果函数未部署，请通过 Dashboard 部署："
echo "  1. 复制 supabase/functions/search-word/index.ts 的内容"
echo "  2. 在 Dashboard 中创建/更新 search-word 函数"
echo "  3. 复制 supabase/functions/generate-story/index.ts 的内容"
echo "  4. 在 Dashboard 中创建/更新 generate-story 函数"

