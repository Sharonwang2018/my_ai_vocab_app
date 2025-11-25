import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_model.dart';

class NotebookService {
  final _supabase = Supabase.instance.client;

  // 获取当前用户ID (如果没有登录，可能是匿名ID)
  String get _userId => _supabase.auth.currentUser?.id ?? '';

  // 检查单词是否已收藏
  Future<bool> isWordSaved(String wordId) async {
    final userId = _supabase.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return false;
    try {
      final response = await _supabase
          .from('user_vocab')
          .select()
          .eq('user_id', userId)
          .eq('word_id', wordId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      print("Check saved error: $e");
      return false; // 如果查询失败，返回 false
    }
  }

  // 切换收藏状态
  Future<void> toggleSaveWord(String wordId) async {
    // 确保用户已登录（匿名或正常）
    var currentUser = _supabase.auth.currentUser;
    
    // 如果用户未登录，先尝试匿名登录
    
    // 如果未登录，尝试匿名登录（最多重试3次）
    if (currentUser == null) {
      int retries = 3;
      String? lastError;
      
      while (retries > 0 && currentUser == null) {
        try {
          final response = await _supabase.auth.signInAnonymously();
          currentUser = response.user;
          if (currentUser != null) {
            final userId = currentUser.id;
            if (userId.isNotEmpty) {
              print("✅ Anonymous login successful: $userId");
              break;
            } else {
              lastError = "用户ID为空";
            }
          } else {
            lastError = "登录响应为空";
          }
        } catch (e) {
          lastError = e.toString();
          print("❌ Anonymous login error (retries left: $retries): $e");
          retries--;
          if (retries > 0) {
            await Future.delayed(const Duration(milliseconds: 1000));
          }
        }
      }
      
      if (currentUser == null) {
        // 提供更详细的错误信息
        final errorMsg = lastError ?? "未知错误";
        
        // 检查是否是 Anonymous 未启用的错误
        String helpText = "";
        if (errorMsg.contains('anonymous_provider_disabled') || 
            errorMsg.contains('Anonymous sign-ins are disabled')) {
          helpText = """
❌ Anonymous 认证未启用！

🔧 解决步骤：
1. 访问: https://supabase.com/dashboard/project/xsqeicialxvfzfzxjorn/auth/providers
2. 找到 "Anonymous" 提供商
3. 点击并启用 "Enable Anonymous sign-ins" 开关
4. 点击 "Save" 保存
5. 刷新页面重试

📝 详细步骤: 查看 ENABLE_ANONYMOUS_AUTH.md
""";
        } else {
          helpText = """
请检查：
1. Supabase Dashboard -> Authentication -> Providers -> Anonymous 已启用
2. 网络连接正常
3. 刷新页面重试
""";
        }
        
        throw Exception("无法登录: $errorMsg\n\n$helpText");
      }
    }
    
    // 安全地获取用户ID，避免空值错误
    final currentUserId = currentUser?.id ?? '';
    if (currentUserId.isEmpty) {
      throw Exception("无法获取用户信息：用户ID为空。请确保匿名登录成功。");
    }
    
    try {
      final isSaved = await isWordSaved(wordId);
      print("📝 Current saved state: $isSaved for wordId: $wordId");
      
      if (isSaved) {
        // 删除收藏
        print("🗑️ Attempting to delete favorite...");
        try {
          final deleteResult = await _supabase
              .from('user_vocab')
              .delete()
              .eq('user_id', currentUserId)
              .eq('word_id', wordId)
              .select();
          
          print("✅ Delete successful: $deleteResult");
        } catch (e) {
          print("❌ Delete error: $e");
          final errorMsg = e.toString();
          
          if (errorMsg.contains('relation') || errorMsg.contains('does not exist')) {
            throw Exception("数据库表不存在！\n\n请在 Supabase SQL Editor 中执行 schema.sql 创建表。");
          }
          
          if (errorMsg.contains('permission') || errorMsg.contains('policy')) {
            throw Exception("权限不足！\n\n请检查：\n1. user_vocab 表的 RLS 策略\n2. Anonymous 认证已启用");
          }
          
          throw Exception("删除失败: $errorMsg");
        }
      } else {
        // 添加收藏
        print("➕ Attempting to add favorite...");
        try {
          final insertResult = await _supabase
              .from('user_vocab')
              .insert({
                'user_id': currentUserId,
                'word_id': wordId,
              })
              .select();
          
          print("✅ Insert successful: $insertResult");
        } catch (e) {
          print("❌ Insert error: $e");
          final errorMsg = e.toString();
          
          if (errorMsg.contains('duplicate') || errorMsg.contains('unique') || errorMsg.contains('violates unique constraint')) {
            // 如果已存在，忽略错误
            print("ℹ️ Word already saved, ignoring duplicate error");
            return;
          }
          
          // 检查是否是表不存在
          if (errorMsg.contains('relation') || errorMsg.contains('does not exist')) {
            throw Exception("数据库表不存在！\n\n请在 Supabase SQL Editor 中执行 schema.sql 创建表。");
          }
          
          // 检查是否是权限问题
          if (errorMsg.contains('permission') || errorMsg.contains('policy') || errorMsg.contains('RLS')) {
            throw Exception("权限不足！\n\n请检查：\n1. user_vocab 表的 RLS 策略\n2. Anonymous 认证已启用\n3. 用户 ID: $currentUserId");
          }
          
          throw Exception("保存失败: $errorMsg");
        }
      }
    } catch (e) {
      print("❌ Toggle save error: $e");
      print("❌ Error type: ${e.runtimeType}");
      print("❌ Stack trace: ${StackTrace.current}");
      
      if (e is Exception) {
        rethrow;
      }
      throw Exception("操作失败: ${e.toString()}");
    }
  }

  // 获取生词本列表
  Future<List<Word>> getUserNotebookWords() async {
    if (_userId.isEmpty) return [];
    
    try {
      final response = await _supabase
          .from('user_vocab')
          .select('word_id, words(*)') // 关联查询
          .eq('user_id', _userId)
          .order('created_at');

      if (response == null) return [];
      
      List<Word> words = [];
      for (var item in response) {
        if (item != null && item['words'] != null) {
          try {
            words.add(Word.fromJson(item['words']));
          } catch (e) {
            print("Error parsing word: $e");
            // 跳过无效的数据
          }
        }
      }
      return words;
    } catch (e) {
      print("Error loading notebook words: $e");
      return [];
    }
  }
}
