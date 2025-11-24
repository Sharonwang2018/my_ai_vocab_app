// 测试 OpenRouter API 连接
const https = require('https');

const OPENROUTER_API_KEY = "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";

console.log("🧪 测试 OpenRouter API 连接...");
console.log("使用模型: deepseek/deepseek-chat");
console.log("");

const data = JSON.stringify({
  model: 'deepseek/deepseek-chat',
  messages: [
    {
      role: 'system',
      content: 'You are a helpful assistant that creates educational content for children learning English vocabulary.'
    },
    {
      role: 'user',
      content: 'Please provide information about the word "volcano" in JSON format with: {"definition_zh": "中文", "definition_en_simple": "English", "definition_ai_kid": "kid-friendly", "tags": ["nature"], "image_url": ""}'
    }
  ],
  temperature: 0.7,
  max_tokens: 400,
});

const options = {
  hostname: 'openrouter.ai',
  port: 443,
  path: '/api/v1/chat/completions',
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
    'Content-Type': 'application/json',
    'HTTP-Referer': 'https://my-ai-vocab-app.com',
    'X-Title': 'AI Kids Vocab App',
  }
};

const req = https.request(options, (res) => {
  let responseData = '';

  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    try {
      const json = JSON.parse(responseData);
      
      if (res.statusCode === 200) {
        console.log("✅ OpenRouter API 测试成功!");
        console.log("");
        console.log("📄 响应内容:");
        const content = json.choices?.[0]?.message?.content || 'No content';
        console.log(content.substring(0, 300) + (content.length > 300 ? '...' : ''));
        console.log("");
        console.log("✅ 代码逻辑正确，可以部署到 Supabase!");
      } else {
        console.log("❌ API 返回错误:");
        console.log(JSON.stringify(json, null, 2));
      }
    } catch (e) {
      console.log("❌ 解析响应失败:");
      console.log(responseData.substring(0, 500));
    }
  });
});

req.on('error', (error) => {
  console.error("❌ 请求失败:", error.message);
});

req.write(data);
req.end();

