#!/bin/bash

# AWS Amplify 自动部署脚本
# 运行此脚本前，请确保已为 AWS 用户添加 Amplify 权限

echo "正在创建 AWS Amplify 应用..."

# 创建 Amplify 应用
APP_RESPONSE=$(aws amplify create-app \
  --name my-ai-vocab-app \
  --repository https://github.com/Sharonwang2018/my_ai_vocab_app \
  --platform WEB \
  --environment-variables \
    SUPABASE_URL=${SUPABASE_URL},SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --output json 2>&1)

if [ $? -eq 0 ]; then
  APP_ID=$(echo $APP_RESPONSE | grep -o '"appId":"[^"]*' | cut -d'"' -f4)
  echo "应用创建成功! App ID: $APP_ID"
  
  echo "正在创建 main 分支..."
  aws amplify create-branch --app-id $APP_ID --branch-name main
  
  echo "正在启动部署..."
  aws amplify start-job --app-id $APP_ID --branch-name main --job-type RELEASE
  
  echo ""
  echo "部署已启动! 请访问 AWS Amplify Console 查看进度:"
  echo "https://console.aws.amazon.com/amplify/home?region=us-east-1#/$APP_ID"
  echo ""
  echo "部署完成后，你可以在 Amplify Console 中找到应用域名。"
else
  echo "错误: $APP_RESPONSE"
  echo ""
  echo "请确保:"
  echo "1. AWS 用户已添加 Amplify 权限"
  echo "2. AWS CLI 已正确配置"
  echo ""
  echo "或者按照 DEPLOYMENT.md 中的说明手动在 AWS Console 中设置。"
fi

