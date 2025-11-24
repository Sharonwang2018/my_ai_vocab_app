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
    final data = await _supabase
        .from('user_vocab')
        .select()
        .eq('user_id', userId)
        .eq('word_id', wordId)
        .maybeSingle();
    return data != null;
  }

  // 切换收藏状态
  Future<void> toggleSaveWord(String wordId) async {
    // 如果用户未登录，尝试匿名登录
    if (_userId.isEmpty) {
      try {
        await _supabase.auth.signInAnonymously();
      } catch (e) {
        // 如果匿名登录失败，使用临时用户ID
        throw Exception("无法保存，请检查网络连接");
      }
    }
    
    final currentUserId = _supabase.auth.currentUser?.id ?? '';
    if (currentUserId.isEmpty) {
      throw Exception("无法获取用户信息");
    }
    
    final isSaved = await isWordSaved(wordId);
    if (isSaved) {
      await _supabase.from('user_vocab').delete().eq('user_id', currentUserId).eq('word_id', wordId);
    } else {
      await _supabase.from('user_vocab').insert({'user_id': currentUserId, 'word_id': wordId});
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
