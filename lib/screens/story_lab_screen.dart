import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/word_model.dart';
import '../services/notebook_service.dart';

class StoryLabScreen extends StatefulWidget {
  const StoryLabScreen({super.key});
  @override
  State<StoryLabScreen> createState() => _StoryLabScreenState();
}

class _StoryLabScreenState extends State<StoryLabScreen> {
  final _notebookService = NotebookService();
  List<Word> _words = [];
  final Set<String> _selectedIds = {};
  String? _story;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _notebookService.getUserNotebookWords();
    if (mounted) setState(() => _words = data);
  }

  void _makeStory() async {
    setState(() { _loading = true; _story = null; });
    try {
      // ✅ 修复点：加了 .client
      final res = await Supabase.instance.client.functions.invoke('generate-story', body: {
        'wordIds': _selectedIds.toList(), 'theme': 'Funny Adventure'
      });
      if (mounted) {
        final storyData = res.data;
        final story = storyData != null && storyData is Map ? storyData['story'] : null;
        setState(() { 
          _story = story?.toString() ?? '生成失败，请重试';
          _loading = false; 
        });
      }
    } catch (e) {
      print("Error: $e"); // 打印错误方便调试
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("生成失败: ${e.toString()}")));
      }
    }
  }
  
  // 故事生成加载状态卡片
  Widget _buildStoryLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 旋转的故事书动画
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: const Icon(
                  Icons.auto_stories,
                  size: 80,
                  color: Colors.purple,
                ),
              );
            },
            onEnd: () {
              if (_loading && mounted) {
                setState(() {}); // 重新触发动画
              }
            },
          ),
          const SizedBox(height: 30),
          const Text(
            "📚 AI 正在创作魔法故事...",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "正在将选中的单词编织成精彩故事",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 30),
          // 进度条
          const LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            minHeight: 6,
          ),
          const SizedBox(height: 20),
          const Text(
            "请稍候，故事即将完成...",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AppBar 由 MainNavScreen 统一管理
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("选择 2-5 个单词:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_words.isEmpty) 
            const Padding(padding: EdgeInsets.all(10), child: Text("生词本是空的，快去搜索一些词吧！")),
          
          Wrap(
            spacing: 8,
            children: _words.map((w) => FilterChip(
              label: Text(w.word),
              selected: _selectedIds.contains(w.id),
              onSelected: (val) => setState(() {
                if (val && _selectedIds.length >= 5) return; // 限制最多5个
                val ? _selectedIds.add(w.id) : _selectedIds.remove(w.id);
              }),
              selectedColor: Colors.purpleAccent[100],
            )).toList(),
          ),
          
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_selectedIds.length < 2 || _loading) ? null : _makeStory,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
              icon: _loading ? const SizedBox() : const Icon(Icons.auto_awesome),
              label: _loading ? const Text("AI 正在创作...") : const Text("生成魔法故事"),
            ),
          ),
          
          const SizedBox(height: 20),
          // 加载状态显示
          if (_loading) _buildStoryLoadingCard(),
          if (_story != null && !_loading) Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1), 
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.orange.withOpacity(0.3))
            ),
            child: MarkdownBody(
              data: _story!,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 16, height: 1.6),
                strong: const TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
