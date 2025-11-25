import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/magic_search_screen.dart';
import 'screens/story_lab_screen.dart';

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
      print("Anonymous login successful: ${authResponse.user!.id}");
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
  final List<Widget> _pages = [
    const MagicSearchScreen(),
    const StoryLabScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: '魔法搜索'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_stories), label: '故事实验'),
        ],
      ),
    );
  }
}
