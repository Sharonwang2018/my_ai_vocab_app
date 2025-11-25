import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_model.dart';

class WordService {
  final _supabase = Supabase.instance.client;

  // 调用后端的 search-word 函数
  Future<Word> searchAndGenerateWord(String query) async {
    try {
      final response = await _supabase.functions.invoke(
        'search-word',
        body: {'word': query.trim()},
      );

      if (response.status != 200) {
        throw Exception('AI 生成失败: HTTP ${response.status}');
      }

      final data = response.data;
      if (data == null) {
        throw Exception('AI 生成失败: 响应数据为空');
      }

      return Word.fromJson(data);
    } catch (e) {
      print('API Error: $e');
      rethrow;
    }
  }
}
