# AI Kids Vocab App

一个使用 Flutter、Supabase 和 OpenAI 构建的儿童词汇学习应用。

A Flutter app for kids vocabulary learning built with Supabase and OpenAI.

## 功能特性 / Features

- 🔍 魔法搜索：使用 AI 搜索和生成单词信息
- 📚 故事实验室：从收藏的单词生成故事
- 💾 生词本：保存和管理学习过的单词

## 技术栈 / Tech Stack

- Flutter (Web)
- Supabase (后端数据库和认证)
- OpenAI (AI 功能)

## 部署 / Deployment

代码已推送到 GitHub: https://github.com/Sharonwang2018/my_ai_vocab_app

### AWS Amplify 部署说明

请查看 [DEPLOYMENT.md](./DEPLOYMENT.md) 获取详细的部署步骤。

**快速开始：**

1. 为 AWS 用户添加 Amplify 权限（IAM -> awsuser -> Add permissions -> AmplifyFullAccess）
2. 访问 [AWS Amplify Console](https://console.aws.amazon.com/amplify)
3. 创建新应用，连接到 GitHub 仓库
4. 设置环境变量（见 DEPLOYMENT.md）
5. 部署应用

部署完成后，你会获得一个类似 `https://main.xxxxx.amplifyapp.com` 的域名。

## 环境变量 / Environment Variables

应用使用以下环境变量（通过 AWS Amplify 配置）：

- `SUPABASE_URL`: Supabase 项目 URL（必需）
- `SUPABASE_ANON_KEY`: Supabase 匿名密钥（必需）

**注意：** 
- 所有敏感密钥都通过环境变量配置，不会提交到代码仓库
- 代码中不包含任何硬编码的密钥
- OpenAI 密钥在 Supabase Edge Functions 中配置（在 Supabase 项目设置中）

## 本地开发 / Local Development

```bash
flutter pub get
flutter run -d chrome
```

## 许可证 / License

MIT
