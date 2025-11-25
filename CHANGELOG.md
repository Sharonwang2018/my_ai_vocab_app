# Changelog

## [1.0.0.0] - 2024-11-24

### 🎉 初始版本发布

#### ✨ 新功能
- **单词搜索功能**: 使用 AI 生成单词定义（中文和英文）
- **真实图片生成**: 基于单词描述生成真实、高质量的图片（使用 Pollinations.ai）
- **故事生成**: 根据选中的单词生成儿童故事
- **单词收藏**: 保存喜欢的单词到笔记本

#### 🎨 用户体验改进
- **Enter 键搜索**: 输入单词后按 Enter 键即可搜索，无需点击图标
- **图片完整显示**: 图片使用 `BoxFit.contain` 完整显示，不被裁剪
- **加载状态**: 图片加载时显示进度指示器
- **错误处理**: 图片加载失败时显示友好的错误提示

#### 🔧 技术实现
- **后端**: Supabase Edge Functions
  - `search-word`: 搜索单词并生成定义和图片
  - `generate-story`: 根据单词生成故事
- **前端**: Flutter Web 应用
  - 响应式设计
  - 现代化 UI
- **API 集成**:
  - DeepSeek API (通过 ProbeX 代理)
  - Pollinations.ai (免费图片生成)
- **部署**:
  - 前端: AWS S3 静态网站托管
  - 后端: Supabase Edge Functions

#### 📝 配置
- 所有敏感信息通过环境变量管理
- Supabase URL 和密钥通过 `--dart-define` 传递
- API 密钥存储在 Supabase Secrets

#### 🐛 已知问题
- 无

#### 📚 文档
- 完整的部署指南
- 环境变量配置说明
- API 使用文档

---

## 版本说明

### 版本格式: MAJOR.MINOR.PATCH.BUILD
- **MAJOR**: 重大功能更新或架构变更
- **MINOR**: 新功能添加
- **PATCH**: Bug 修复
- **BUILD**: 构建号

### 当前版本: 1.0.0.0
这是应用的第一个正式版本，包含所有核心功能。


