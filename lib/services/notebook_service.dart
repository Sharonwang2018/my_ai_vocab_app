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
    
    // 如果未登录，尝试匿名登录（最多重试3次）
    if (currentUser == null) {
      int retries = 3;
      String? lastError;
      
      while (retries > 0 && currentUser == null) {
        try {
          final response = await _supabase.auth.signInAnonymously();
          currentUser = response.user;
          if (currentUser != null) {
            print("✅ Anonymous login successful: ${currentUser.id}");
            break;
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
        throw Exception("无法登录: $errorMsg\n\n请检查：\n1. Supabase Dashboard -> Authentication -> Providers -> Anonymous 已启用\n2. 网络连接正常\n3. 刷新页面重试");
      }
    }
    
    final currentUserId = currentUser.id;
    if (currentUserId.isEmpty) {
      throw Exception("无法获取用户信息");
    }
    
    try {
      final isSaved = await isWordSaved(wordId);
      if (isSaved) {
        // 删除收藏
        final deleteResponse = await _supabase
            .from('user_vocab')
            .delete()
            .eq('user_id', currentUserId)
            .eq('word_id', wordId);
        
        if (deleteResponse.hasError) {
          final error = deleteResponse.error;
          print("❌ Delete error: ${error?.message}");
          throw Exception("删除失败: ${error?.message ?? '未知错误'}\n\n可能原因：\n- user_vocab 表不存在\n- RLS 策略阻止操作\n- 权限不足");
        }
      } else {
        // 添加收藏
        final insertResponse = await _supabase
            .from('user_vocab')
            .insert({
              'user_id': currentUserId,
              'word_id': wordId,
            });
        
        if (insertResponse.hasError) {
          final error = insertResponse.error;
          print("❌ Insert error: ${error?.message}");
          
          if (error?.message?.contains('duplicate') ?? false) {
            // 如果已存在，忽略错误
            return;
          }
          
          // 检查是否是表不存在
          if (error?.message?.contains('relation') ?? false || 
              error?.message?.contains('does not exist') ?? false) {
            throw Exception("数据库表不存在！\n\n请在 Supabase SQL Editor 中执行 schema.sql 创建表。");
          }
          
          // 检查是否是权限问题
          if (error?.message?.contains('permission') ?? false || 
              error?.message?.contains('policy') ?? false) {
            throw Exception("权限不足！\n\n请检查：\n1. user_vocab 表的 RLS 策略\n2. Anonymous 认证已启用");
          }
          
          throw Exception("保存失败: ${error?.message ?? '未知错误'}");
        }
      }
    } catch (e) {
      print("❌ Toggle save error: $e");
      if (e is Exception) {
        rethrow;
      }
      throw Exception("操作失败: ${e.toString()}");
    }
  }

  // 获取生词本列表
  Future<List<Word>> getUserNotebookWords() async {
    if (_userId.isEmpty) return [];
    
    final data = await _supabase
        .from('user_vocab')
        .select('word_id, words(*)') // 关联查询
        .eq('user_id', _userId)
        .order('created_at');

    List<Word> words = [];
    for (var item in data) {
      if (item['words'] != null) {
        words.add(Word.fromJson(item['words']));
      }
    }
    return words;
  }
}
