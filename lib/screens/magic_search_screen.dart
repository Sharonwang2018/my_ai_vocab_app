import 'package:flutter/material.dart';
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

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(_currentWord!.imageUrl, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                right: 10, top: 10,
                child: FloatingActionButton.small(
                  backgroundColor: Colors.white,
                  onPressed: _toggleHeart,
                  child: Icon(_isSaved ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          Text(_currentWord!.word, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          Text(_currentWord!.definitionZh, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          const Divider(height: 30),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🦉 Lexi 老师说:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 5),
                Text(_currentWord!.definitionAiKid, style: const TextStyle(fontSize: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
