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
    if (currentUser == null) {
      try {
        final response = await _supabase.auth.signInAnonymously();
        currentUser = response.user;
        if (currentUser == null) {
          throw Exception("登录失败，请重试");
        }
      } catch (e) {
        print("Anonymous login error: $e");
        throw Exception("无法登录，请检查网络连接或刷新页面重试");
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
          throw Exception("删除失败: ${deleteResponse.error?.message ?? '未知错误'}");
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
          if (error?.message?.contains('duplicate') ?? false) {
            // 如果已存在，忽略错误
            return;
          }
          throw Exception("保存失败: ${error?.message ?? '未知错误'}");
        }
      }
    } catch (e) {
      print("Toggle save error: $e");
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
