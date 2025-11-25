import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:html' as html;
import '../models/word_model.dart';
import '../services/word_service.dart';
import '../services/notebook_service.dart';
import '../services/user_service.dart';

class MagicSearchScreen extends StatefulWidget {
  const MagicSearchScreen({super.key});
  @override
  State<MagicSearchScreen> createState() => _MagicSearchScreenState();
}

class _MagicSearchScreenState extends State<MagicSearchScreen> {
  final _controller = TextEditingController();
  final _wordService = WordService();
  final _notebookService = NotebookService();
  final _userService = UserService();
  
  Word? _currentWord;
  bool _isLoading = false;
  bool _isSaved = false;

  void _handleSearch() async {
    if (_controller.text.isEmpty) return;
    final searchWord = _controller.text.trim();
    FocusScope.of(context).unfocus();
    setState(() { _isLoading = true; _currentWord = null; _isSaved = false; });
    
    // 搜索成功后清空输入框
    _controller.clear();

    try {
      final word = await _wordService.searchAndGenerateWord(searchWord);
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
    final word = _currentWord;
    if (word == null || word.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('无法收藏：单词信息不完整'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // 乐观更新UI
    final previousState = _isSaved;
    setState(() => _isSaved = !_isSaved);
    try {
      await _notebookService.toggleSaveWord(word.id);
      // 更新状态以反映实际保存状态
      final actualState = await _notebookService.isWordSaved(word.id);
      if (mounted) {
        setState(() => _isSaved = actualState);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(actualState ? '已加入生词库' : '已从生词库移除'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // 回滚
      if (mounted) {
        setState(() => _isSaved = previousState);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // AppBar 由 MainNavScreen 统一管理
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 用户信息显示（更明显）
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _userService.isLoggedIn ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _userService.isLoggedIn ? Colors.blue : Colors.grey,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.person,
                  color: _userService.isLoggedIn ? Colors.blue : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userService.isLoggedIn ? '已登录' : '未登录',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _userService.isLoggedIn ? Colors.blue : Colors.grey,
                        ),
                      ),
                      Text(
                        '用户 ID: ${_userService.getShortUserId()}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_userService.isLoggedIn)
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
          ),
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
            
            if (_isLoading) _buildLoadingCard(),
            
            if (_currentWord != null && !_isLoading) _buildCard(),
          ],
        ),
    );
  }

  // 定义一个 Google 蓝颜色常量
  static const Color post_primary_blue = Color(0xFF1A73E8);
  
  // 加载状态卡片 - 让用户知道进度，不会退出
  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 旋转的魔法棒动画
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: Colors.purple,
                ),
              );
            },
            onEnd: () {
              if (_isLoading && mounted) {
                setState(() {}); // 重新触发动画
              }
            },
          ),
          const SizedBox(height: 30),
          const Text(
            "✨ AI 正在施法...",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "正在生成单词释义和图片",
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
            "请稍候，魔法即将完成...",
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
  
  // 图片重试机制：如果主URL失败，尝试备用URL
  Widget _buildImageWithRetry(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              SizedBox(height: 10),
              Text('图片生成中...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    // 生成备用URL（添加 realistic 修饰符）
    final primaryUrl = imageUrl;
    final fallbackUrl = imageUrl.replaceAll(
      RegExp(r'\?width=\d+&height=\d+'),
      ' realistic photograph?width=1024&height=1024'
    );
    
    return Image.network(
      primaryUrl,
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
      errorBuilder: (context, error, stackTrace) {
        // 如果主URL失败，尝试备用URL
        if (fallbackUrl != primaryUrl) {
          return Image.network(
            fallbackUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) => 
              Container(
                height: 200, 
                color: Colors.grey[200], 
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text('图片暂时无法加载', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
          );
        }
        
        // 如果备用URL也失败，显示错误
        return Container(
          height: 200, 
          color: Colors.grey[200], 
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                SizedBox(height: 10),
                Text('图片暂时无法加载', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }

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
    final word = _currentWord;
    if (word == null) return const SizedBox.shrink(); // Should not happen if _currentWord is checked
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
                  word.word,
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
              _buildAudioBtn("US", word.phoneticUs, "en-US", word.word),
              const SizedBox(width: 15),
              _buildAudioBtn("UK", word.phoneticUk, "en-GB", word.word),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)), // 细分割线
          const SizedBox(height: 20),

          // ------------------------------------------------
          // 3. 词性 (italic 灰色斜体)
          // ------------------------------------------------
          Text(
            word.partOfSpeech.toLowerCase(),
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
            word.definitionEnSimple,
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
            word.definitionZh,
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
                  child: _buildImageWithRetry(word.imageUrl),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "记忆小贴士: ${word.definitionAiKid}",
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
  Widget _buildAudioBtn(String label, String phonetic, String accent, String word) {
    return InkWell(
      onTap: () => _speak(word, accent),
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
                Text(label, style: const TextStyle(fontSize: 10, color: post_primary_blue, fontWeight: FontWeight.bold)),
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
