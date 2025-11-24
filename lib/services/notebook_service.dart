import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_model.dart';

class NotebookService {
  final _supabase = Supabase.instance.client;

  // 获取当前用户ID (如果没有登录，可能是匿名ID)
  String get _userId => _supabase.auth.currentUser?.id ?? '';

  // 检查单词是否已收藏
  Future<bool> isWordSaved(String wordId) async {
    if (_userId.isEmpty) return false;
    final data = await _supabase
        .from('user_vocab')
        .select()
        .eq('user_id', _userId)
        .eq('word_id', wordId)
        .maybeSingle();
    return data != null;
  }

  // 切换收藏状态
  Future<void> toggleSaveWord(String wordId) async {
    if (_userId.isEmpty) throw Exception("请先登录");
    
    final isSaved = await isWordSaved(wordId);
    if (isSaved) {
      await _supabase.from('user_vocab').delete().eq('user_id', _userId).eq('word_id', wordId);
    } else {
      await _supabase.from('user_vocab').insert({'user_id': _userId, 'word_id': wordId});
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
