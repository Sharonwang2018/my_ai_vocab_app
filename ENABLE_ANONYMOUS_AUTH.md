# 🔐 启用 Anonymous 认证 - 解决收藏功能错误

## ❌ 当前错误

```
操作失败: Exception: 无法登录: AuthApiException 
(message: Anonymous sign-ins are disabled, 
statusCode: 422, 
code: anonymous_provider_disabled)
```

## ✅ 解决方案：启用 Anonymous 认证

### 步骤 1: 访问 Supabase Dashboard

1. 打开: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers

### 步骤 2: 找到 Anonymous 提供商

在认证提供商列表中，找到 **"Anonymous"** 选项。

### 步骤 3: 启用 Anonymous

1. 点击 **"Anonymous"** 提供商
2. 找到 **"Enable Anonymous sign-ins"** 开关
3. **将开关切换到 ON（绿色）**
4. 点击 **"Save"** 保存

### 步骤 4: 验证

1. 刷新应用页面（Cmd+R 或 Ctrl+R）
2. 搜索一个单词（如 "apple"）
3. 点击 heart 图标
4. 应该显示 "已加入生词库" 而不是错误

## 📸 详细步骤（带截图说明）

### 在 Supabase Dashboard 中：

1. **导航到 Authentication**
   - 左侧菜单 → **Authentication**
   - 点击 **Providers** 标签

2. **找到 Anonymous**
   - 在提供商列表中向下滚动
   - 找到 **"Anonymous"** 选项

3. **启用 Anonymous**
   - 点击 **"Anonymous"** 卡片
   - 在弹出窗口中，找到 **"Enable Anonymous sign-ins"** 开关
   - **打开开关**（应该变成绿色）
   - 点击 **"Save"** 按钮

4. **确认已启用**
   - 返回提供商列表
   - **"Anonymous"** 应该显示为 **"Enabled"**（绿色）

## 🔍 如果仍然失败

### 检查清单：

- [ ] Anonymous 开关已打开（绿色）
- [ ] 已点击 "Save" 保存
- [ ] 已刷新应用页面
- [ ] 网络连接正常

### 如果已启用但仍然失败：

1. **尝试重新启用**
   - 禁用 Anonymous（关闭开关）
   - 保存
   - 等待 5 秒
   - 重新启用 Anonymous（打开开关）
   - 保存
   - 刷新应用页面

2. **检查浏览器控制台**
   - 按 F12 打开开发者工具
   - 切换到 "Console" 标签
   - 查看是否有其他错误信息

3. **检查 Supabase Logs**
   - 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/logs/edge-logs
   - 查看是否有认证相关的错误

## 🎯 快速链接

- **直接访问 Anonymous 设置**: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers
- **Supabase 文档**: https://supabase.com/docs/guides/auth/auth-anonymous

## ✅ 启用后

启用 Anonymous 认证后：
- ✅ 用户可以匿名登录
- ✅ 收藏功能可以正常工作
- ✅ 每个用户都有唯一的匿名 ID
- ✅ 数据存储在 `user_vocab` 表中


