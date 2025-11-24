class Word {
  final String id;
  final String word;
  final String definitionZh;
  final String definitionEnSimple;
  final String definitionAiKid;
  final String imageUrl;
  final List<String> tags;

  Word({
    required this.id,
    required this.word,
    required this.definitionZh,
    required this.definitionEnSimple,
    required this.definitionAiKid,
    required this.imageUrl,
    required this.tags,
  });

  // 把后端返回的 JSON 数据变成 App 能用的对象
  factory Word.fromJson(Map<String, dynamic> json) {
    final content = json['content'] ?? {};
    final assets = json['assets'] ?? {};

    return Word(
      id: json['id'] ?? '',
      word: json['word'] ?? '',
      definitionZh: content['definition_zh'] ?? '暂无中文',
      definitionEnSimple: content['definition_en_simple'] ?? '',
      definitionAiKid: content['definition_ai_kid'] ?? '思考中...',
      imageUrl: assets['image_url'] ?? '',
      tags: List<String>.from(content['tags'] ?? []),
    );
  }
}
