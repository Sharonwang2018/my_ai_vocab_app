# 本地测试故障排除指南

## 问题：http://localhost:8080/ 显示空白页面

### 可能的原因和解决方案

#### 1. 应用还在编译中 ⏳
**症状：** 页面是空白的，但浏览器控制台没有错误

**解决方案：**
- 等待 1-2 分钟让 Flutter 完成编译
- 查看终端输出，应该会显示 "Compiling lib/main.dart for the Web..."
- 编译完成后，浏览器会自动刷新

#### 2. JavaScript 加载失败 ❌
**症状：** 浏览器控制台显示 404 错误（找不到 main.dart.js）

**解决方案：**
```bash
# 停止当前服务器
pkill -f "flutter run"

# 清理并重新启动
cd /Users/ss/my_ai_vocab_app
flutter clean
flutter pub get
flutter run -d chrome --web-port=8080 \
  --dart-define=SUPABASE_URL=https://xsqeicialxvfzfzxjorn.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzcWVpY2lhbHh2Znpmenhqb3JuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3ODA2ODIsImV4cCI6MjA3OTM1NjY4Mn0.hIOzK-O1yohy1bGsOIK0p3ttJMePfS9NHzVs1GE2-Xg
```

#### 3. 应用初始化错误 🐛
**症状：** 浏览器控制台显示 JavaScript 错误

**常见错误：**
- `SUPABASE_URL and SUPABASE_ANON_KEY must be set` - 环境变量未设置
- `Anonymous sign-ins are disabled` - Supabase 匿名认证未启用
- `Null check operator used on a null value` - 空值检查错误

**解决方案：**
- 检查浏览器控制台的完整错误信息
- 确保 Supabase 配置正确
- 确保所有空值检查都已修复

#### 4. 端口被占用 🔒
**症状：** 终端显示 "Address already in use"

**解决方案：**
```bash
# 清理端口
lsof -ti:8080 | xargs kill -9

# 或使用其他端口
flutter run -d chrome --web-port=8081
```

### 检查步骤

1. **打开浏览器控制台（F12 或 Cmd+Option+I）**
   - 查看 Console 标签中的错误
   - 查看 Network 标签中资源加载状态

2. **检查终端输出**
   - 应该看到 "Launching lib/main.dart on Chrome"
   - 应该看到 "Compiling lib/main.dart for the Web..."
   - 编译完成后会显示 "✓ Built build/web"

3. **手动检查文件**
   ```bash
   # 检查 main.dart.js 是否存在
   curl -I http://localhost:8080/main.dart.js
   
   # 应该返回 200 OK
   ```

### 如果问题仍然存在

请提供以下信息：
1. 浏览器控制台的完整错误信息（截图或复制文本）
2. 终端中的完整输出
3. Network 标签中失败的请求详情

