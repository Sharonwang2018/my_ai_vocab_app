# 用户会话和词汇表管理说明

## 工作原理

### 1. 匿名认证（Automatic）
- **无需登录界面**：应用启动时自动创建匿名用户
- **每个浏览器会话**：自动获得一个唯一的用户 ID（UUID）
- **持久化**：Supabase 自动将用户 ID 存储在浏览器的 localStorage 中
- **跨标签页**：同一浏览器的所有标签页共享同一个用户会话

### 2. 用户识别
- **显示位置**：AppBar 右上角
- **显示格式**：`ID: xxxxxxxx`（用户 ID 的前 8 位）
- **点击查看**：点击用户图标可查看完整信息和词汇数量

### 3. 词汇表隔离
- **每个用户独立**：每个匿名用户有自己独立的词汇表
- **数据存储**：词汇表存储在 Supabase 的 `user_vocab` 表中
- **关联方式**：通过 `user_id` 字段关联到 `auth.users` 表

### 4. 切换用户功能
- **用途**：允许在同一设备上创建新的匿名用户
- **效果**：
  - 清除当前会话
  - 创建新的匿名用户（新的 UUID）
  - 新用户有独立的词汇表
  - **注意**：旧用户的词汇表数据不会丢失，只是无法访问（除非记住旧用户 ID）

## 技术实现

### 会话管理
```dart
// 自动匿名登录（在 main.dart 中）
await Supabase.instance.client.auth.signInAnonymously();

// 用户 ID 存储在 Supabase 的 auth 系统中
final userId = Supabase.instance.client.auth.currentUser?.id;
```

### 数据隔离
```sql
-- user_vocab 表结构
CREATE TABLE user_vocab (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),  -- 关联到匿名用户
  word_id UUID REFERENCES words(id),
  created_at TIMESTAMP
);

-- RLS 策略确保用户只能访问自己的数据
CREATE POLICY "Users can view their own vocab"
  ON user_vocab FOR SELECT
  USING (auth.uid() = user_id);
```

### 浏览器存储
- **Supabase SDK** 自动管理：
  - 用户 token 存储在 `localStorage`
  - 会话信息存储在 `sessionStorage`
  - 刷新页面后自动恢复会话

## 使用场景

### 场景 1：单个用户
- 用户 A 打开应用 → 自动创建匿名用户 `abc12345`
- 收藏单词 → 存储在 `user_vocab` 表中，`user_id = abc12345`
- 关闭浏览器 → 会话信息保存在 localStorage
- 重新打开 → 自动恢复会话，词汇表仍然可见

### 场景 2：多个用户（同一设备）
- 用户 A：使用应用，收藏了一些单词
- 用户 B：点击"切换用户" → 创建新用户 `xyz67890`
- 用户 B：收藏单词 → 存储在 `user_vocab` 表中，`user_id = xyz67890`
- **结果**：两个用户的数据完全隔离

### 场景 3：清除浏览器数据
- 清除 localStorage → 会话丢失
- 重新打开应用 → 创建新的匿名用户
- **注意**：旧用户的词汇表数据仍在数据库中，但无法访问（除非记住用户 ID）

## 优势

1. **无需注册**：用户无需提供邮箱或密码
2. **自动管理**：无需手动处理 cookie 或 session
3. **数据安全**：通过 RLS 策略确保数据隔离
4. **跨设备**：如果未来添加登录功能，可以关联到邮箱账户

## 未来改进

1. **导出/导入功能**：允许用户导出词汇表（包含用户 ID）
2. **登录功能**：允许用户将匿名账户关联到邮箱
3. **多设备同步**：登录后可以在多个设备上访问同一词汇表
4. **用户昵称**：允许用户设置昵称而不是显示 UUID

## 常见问题

### Q: 如果清除浏览器数据会怎样？
A: 会话会丢失，应用会创建新的匿名用户。旧数据仍在数据库中，但无法访问。

### Q: 如何在同一设备上使用多个账户？
A: 使用"切换用户"功能，或使用浏览器的"无痕模式"。

### Q: 数据会丢失吗？
A: 不会。数据存储在 Supabase 数据库中，除非手动删除，否则不会丢失。

### Q: 可以恢复之前的用户吗？
A: 如果知道用户 ID，可以手动设置（需要添加此功能）。或者使用"导出/导入"功能保存用户 ID。

