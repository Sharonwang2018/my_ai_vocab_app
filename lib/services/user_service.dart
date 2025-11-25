import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:html' as html;

class UserService {
  final _supabase = Supabase.instance.client;
  
  // 获取当前用户ID
  String? get currentUserId => _supabase.auth.currentUser?.id;
  
  // 获取用户ID的简短显示版本（前8位）
  String getShortUserId() {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) return '未登录';
    return userId.substring(0, 8);
  }
  
  // 获取完整的用户ID
  String? getFullUserId() => currentUserId;
  
  // 检查是否已登录
  bool get isLoggedIn => currentUserId != null;
  
  // 获取用户词汇数量（用于显示）
  Future<int> getUserVocabCount() async {
    final userId = currentUserId;
    if (userId == null || userId.isEmpty) return 0;
    
    try {
      final response = await _supabase
          .from('user_vocab')
          .select('id')
          .eq('user_id', userId);
      
      // 返回列表长度作为计数
      return response.length;
    } catch (e) {
      print("Error getting vocab count: $e");
      return 0;
    }
  }
  
  // 切换用户（登出当前用户并创建新的匿名用户）
  Future<void> switchUser() async {
    try {
      // 登出当前用户
      await _supabase.auth.signOut();
      
      // 清除本地存储（如果有）
      html.window.localStorage.remove('supabase.auth.token');
      
      // 创建新的匿名用户
      final response = await _supabase.auth.signInAnonymously();
      if (response.user != null) {
        print("✅ New anonymous user created: ${response.user!.id}");
      }
    } catch (e) {
      print("Error switching user: $e");
      rethrow;
    }
  }
  
  // 确保用户已登录（如果未登录，创建匿名用户）
  Future<void> ensureLoggedIn() async {
    if (!isLoggedIn) {
      try {
        final response = await _supabase.auth.signInAnonymously();
        if (response.user == null) {
          throw Exception("Failed to create anonymous user");
        }
        print("✅ Anonymous user created: ${response.user!.id}");
      } catch (e) {
        print("Error ensuring login: $e");
        rethrow;
      }
    }
  }
}

