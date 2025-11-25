// 直接测试 DeepSeek API
const https = require('https');

const DEEPSEEK_KEY = 'sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ';

console.log('🧪 测试 DeepSeek API...');
console.log('API Key:', DEEPSEEK_KEY.substring(0, 10) + '...' + DEEPSEEK_KEY.substring(DEEPSEEK_KEY.length - 5));
console.log('模型: deepseek-chat');
console.log('');

const testData = JSON.stringify({
  model: 'deepseek-chat',
  messages: [
    {
      role: 'system',
      content: 'You are a helpful assistant.'
    },
    {
      role: 'user',
      content: 'Say hello in one sentence.'
    }
  ],
  max_tokens: 20,
});

const options = {
  hostname: 'api.deepseek.com',
  port: 443,
  path: '/v1/chat/completions',
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${DEEPSEEK_KEY}`,
    'Content-Type': 'application/json',
  }
};

console.log('📤 发送请求...');
const req = https.request(options, (res) => {
  let body = '';
  
  console.log(`状态码: ${res.statusCode}`);
  console.log('响应头:', res.headers['content-type']);
  console.log('');

  res.on('data', (chunk) => {
    body += chunk;
  });

  res.on('end', () => {
    console.log('📥 收到响应:');
    try {
      const json = JSON.parse(body);
      if (json.error) {
        console.log('❌ API 错误:');
        console.log(JSON.stringify(json.error, null, 2));
        console.log('');
        console.log('可能的原因:');
        console.log('  1. API key 无效或过期');
        console.log('  2. API key 格式不正确');
        console.log('  3. 账户余额不足');
      } else if (json.choices && json.choices.length > 0) {
        console.log('✅ DeepSeek API 工作正常!');
        console.log('模型:', json.model);
        console.log('响应:', json.choices[0].message.content);
        console.log('');
        console.log('🎉 API key 有效，可以继续测试完整函数逻辑!');
      } else {
        console.log('响应:', JSON.stringify(json, null, 2));
      }
    } catch (e) {
      console.log('原始响应:', body);
      console.log('解析错误:', e.message);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ 请求失败:', error.message);
});

req.write(testData);
req.end();


