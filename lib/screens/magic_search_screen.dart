import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../services/notebook_service.dart';

class MagicSearchScreen extends StatefulWidget {
  const MagicSearchScreen({super.key});
  @override
  State<MagicSearchScreen> createState() => _MagicSearchScreenState();
}

class _MagicSearchScreenState extends State<MagicSearchScreen> {
  final _controller = TextEditingController();
  final _wordService = WordService();
  final _notebookService = NotebookService();
  
  Word? _currentWord;
  bool _isLoading = false;
  bool _isSaved = false;

  void _handleSearch() async {
    if (_controller.text.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _currentWord = null; _isSaved = false; });

    try {
      final word = await _wordService.searchAndGenerateWord(_controller.text);
      final isSaved = await _notebookService.isWordSaved(word.id);
      if (mounted) {
        setState(() { _currentWord = word; _isSaved = isSaved; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('出错了: $e')));
      }
    }
  }

  void _toggleHeart() async {
    if (_currentWord == null) return;
    // 乐观更新UI
    setState(() => _isSaved = !_isSaved);
    try {
      await _notebookService.toggleSaveWord(_currentWord!.id);
    } catch (e) {
      setState(() => _isSaved = !_isSaved); // 回滚
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('操作失败，请重试')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🔍 魔法单词搜"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 搜索框
            TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                hintText: "输入单词 (如: Volcano)",
                suffixIcon: IconButton(icon: const Icon(Icons.search, size: 30, color: Colors.blue), onPressed: _handleSearch),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onSubmitted: (_) => _handleSearch(), // 按 Enter 键搜索
              textInputAction: TextInputAction.search, // 设置键盘为搜索模式
            ),
            const SizedBox(height: 30),
            
            if (_isLoading) const Column(
              children: [CircularProgressIndicator(), SizedBox(height: 10), Text("AI 正在施法...")],
            ),
            
            if (_currentWord != null && !_isLoading) _buildCard(),
          ],
        ),
      ),
    );
  }

  // 定义一个 Google 蓝颜色常量
  static const Color post_primary_blue = Color(0xFF1A73E8);

  // 发音功能（使用 Web Speech API）
  void _speak(String word, String accent) {
    try {
      // 使用 Web Speech API
      final utterance = html.SpeechSynthesisUtterance(word);
      if (accent == "en-US") {
        utterance.lang = 'en-US';
      } else if (accent == "en-GB") {
        utterance.lang = 'en-GB';
      }
      html.window.speechSynthesis?.speak(utterance);
    } catch (e) {
      // 如果 Web Speech API 不可用，使用系统提示音
      HapticFeedback.lightImpact();
    }
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity, // 占满宽度
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      padding: const EdgeInsets.all(24), // 增加内边距，看起来更像卡片
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // 所有内容左对齐
        children: [
          // ------------------------------------------------
          // 1. 单词 + 收藏按钮
          // ------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _currentWord!.word,
                  style: const TextStyle(
                    fontSize: 36, 
                    fontWeight: FontWeight.w900, // Google 风格的超粗字体
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: _toggleHeart,
                icon: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved ? Colors.redAccent : Colors.grey[400],
                  size: 28,
                ),
              ),
            ],
          ),

          // ------------------------------------------------
          // 2. 音标 + 发音按钮 (模仿 Google 的蓝色喇叭)
          // ------------------------------------------------
          const SizedBox(height: 8),
          Row(
            children: [
              _buildAudioBtn("US", _currentWord!.phoneticUs, "en-US"),
              const SizedBox(width: 15),
              _buildAudioBtn("UK", _currentWord!.phoneticUk, "en-GB"),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)), // 细分割线
          const SizedBox(height: 20),

          // ------------------------------------------------
          // 3. 词性 (italic 灰色斜体)
          // ------------------------------------------------
          Text(
            _currentWord!.partOfSpeech.toLowerCase(),
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),

          // ------------------------------------------------
          // 4. 英文解释
          // ------------------------------------------------
          Text(
            _currentWord!.definitionEnSimple,
            style: const TextStyle(
              fontSize: 18,
              height: 1.5, // 增加行高，更易读
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // ------------------------------------------------
          // 5. 中文翻译 (灰色辅助)
          // ------------------------------------------------
          Text(
            _currentWord!.definitionZh,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          // ------------------------------------------------
          // 6. AI 辅助图片 (放在最下面)
          // ------------------------------------------------
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)), // 给图片加个边框
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    _currentWord!.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => 
                      Container(
                        height: 200, 
                        color: Colors.grey[200], 
                        child: const Center(child: Icon(Icons.image_not_supported))
                      ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "记忆小贴士: ${_currentWord!.definitionAiKid}",
                          style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔵 专门用来画那个蓝色喇叭按钮的小组件
  Widget _buildAudioBtn(String label, String phonetic, String accent) {
    return InkWell(
      onTap: () => _speak(_currentWord!.word, accent),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F0FE), // Google 风格的浅蓝色背景
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up_rounded, size: 20, color: post_primary_blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(label, style: TextStyle(fontSize: 10, color: post_primary_blue, fontWeight: FontWeight.bold)),
                Text(
                  phonetic.isNotEmpty ? phonetic : "/.../", 
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
