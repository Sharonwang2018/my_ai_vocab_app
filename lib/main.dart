import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/magic_search_screen.dart';
import 'screens/story_lab_screen.dart';
import 'services/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ 从环境变量读取 Supabase 配置（必须设置，无默认值）
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception('SUPABASE_URL and SUPABASE_ANON_KEY must be set as environment variables');
  }
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  // 尝试匿名登录 (请确保你在 Supabase 后台 -> Authentication -> Providers 开启了 Anonymous)
  try {
    final authResponse = await Supabase.instance.client.auth.signInAnonymously();
    if (authResponse.user == null) {
      print("Warning: Anonymous login returned null user");
    } else {
      final userId = authResponse.user?.id ?? '';
      if (userId.isNotEmpty) {
        print("Anonymous login successful: $userId");
      } else {
        print("Warning: Anonymous login returned user with empty ID");
      }
    }
  } catch (e) {
    print("Auth Init Error: $e");
    // 不抛出异常，让应用继续运行，但会在收藏时再次尝试登录
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Kids Vocab',
      debugShowCheckedModeBanner: false, // 去掉右上角的 Debug 标签
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MainNavScreen(),
    );
  }
}

class MainNavScreen extends StatefulWidget {
  const MainNavScreen({super.key});
  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _currentIndex = 0;
  final _userService = UserService();
  int _vocabCount = 0;
  
  final List<Widget> _pages = [
    const MagicSearchScreen(),
    const StoryLabScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _ensureUserLoggedIn();
  }
  
  Future<void> _ensureUserLoggedIn() async {
    // 确保用户已登录
    try {
      await _userService.ensureLoggedIn();
      await _loadUserInfo();
      // 强制刷新 UI
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print("Error ensuring login: $e");
    }
  }
  
  Future<void> _loadUserInfo() async {
    final count = await _userService.getUserVocabCount();
    if (mounted) {
      setState(() => _vocabCount = count);
    }
  }
  
  Future<void> _switchUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换用户'),
        content: const Text('切换用户将清除当前会话并创建新用户。\n\n注意：当前用户的词汇表将无法访问，但数据不会丢失。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('切换'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await _userService.switchUser();
        await _loadUserInfo();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('已切换到新用户')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('切换失败: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                _currentIndex == 0 ? '🔍 魔法单词搜' : '📚 故事实验',
                style: const TextStyle(fontSize: 18),
              ),
            ),
            // 用户信息 - 更明显的显示
            Builder(
              builder: (context) {
                final userId = _userService.getShortUserId();
                final isLoggedIn = _userService.isLoggedIn;
                
                return PopupMenuButton<String>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLoggedIn ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isLoggedIn ? Colors.blue : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person,
                          size: 18,
                          color: isLoggedIn ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          userId,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isLoggedIn ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('用户 ID: ${_userService.getShortUserId()}'),
                          Text('词汇数: $_vocabCount', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'switch',
                      child: const Row(
                        children: [
                          Icon(Icons.swap_horiz, size: 18),
                          SizedBox(width: 8),
                          Text('切换用户'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'switch') {
                      _switchUser();
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          _loadUserInfo(); // 切换页面时刷新用户信息
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '魔法搜索'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: '故事实验'),
        ],
      ),
    );
  }
}
