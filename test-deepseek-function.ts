// 测试完整的 search-word 函数逻辑
const DEEPSEEK_API_KEY = "sk-7XpwEb0Wql59BrrScyWkkxRLD2s5CunbyuofnQPEz6IDdlAJ"
const word = "volcano"

console.log("🧪 测试完整的 search-word 函数逻辑...")
console.log("测试单词:", word)
console.log("")

// 模拟函数中的 DeepSeek API 调用
async function testFunction() {
  try {
    console.log("1️⃣ 调用 DeepSeek API...")
    const deepseekResponse = await fetch('https://api.deepseek.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${DEEPSEEK_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'deepseek-chat',
        messages: [
          {
            role: 'system',
            content: 'You are a helpful assistant that creates educational content for children learning English vocabulary. Provide word definitions in both Chinese and English, examples, and fun facts in a child-friendly way.'
          },
          {
            role: 'user',
            content: `Please provide information about the word "${word}" in JSON format with the following structure: {
              "definition_zh": "中文定义（简单易懂）",
              "definition_en_simple": "simple English definition for children",
              "definition_ai_kid": "a fun, kid-friendly explanation",
              "tags": ["tag1", "tag2"],
              "image_url": ""
            }`
          }
        ],
        temperature: 0.7,
        max_tokens: 400,
      }),
    })

    if (!deepseekResponse.ok) {
      const errorText = await deepseekResponse.text()
      console.error("❌ DeepSeek API 错误:")
      console.error(errorText)
      return false
    }

    console.log("✅ DeepSeek API 调用成功!")
    console.log("")

    const deepseekData = await deepseekResponse.json()
    const content = deepseekData.choices[0]?.message?.content || '{}'
    
    console.log("2️⃣ 解析响应内容...")
    console.log("原始内容:", content.substring(0, 200) + "...")
    console.log("")

    // 解析 JSON
    let aiContent
    try {
      const jsonMatch = content.match(/```json\s*([\s\S]*?)\s*```/) || content.match(/```\s*([\s\S]*?)\s*```/)
      const jsonString = jsonMatch ? jsonMatch[1] : content
      aiContent = JSON.parse(jsonString)
      console.log("✅ JSON 解析成功!")
      console.log("解析结果:", JSON.stringify(aiContent, null, 2))
    } catch (e) {
      console.log("⚠️  JSON 解析失败，使用备用方案")
      aiContent = {
        definition_zh: '暂无中文定义',
        definition_en_simple: content.substring(0, 200),
        definition_ai_kid: content.substring(0, 150),
        tags: [],
        image_url: ''
      }
    }

    console.log("")
    console.log("3️⃣ 生成图片 URL...")
    const targetWord = word.toLowerCase()
    const imageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(targetWord)}%20cartoon%20cute?width=1024&height=1024`
    console.log("图片 URL:", imageUrl)
    console.log("")

    console.log("4️⃣ 构建最终响应...")
    const wordData = {
      id: 'test-id',
      word: word.toLowerCase(),
      content: {
        definition_zh: aiContent.definition_zh || '暂无中文',
        definition_en_simple: aiContent.definition_en_simple || '',
        definition_ai_kid: aiContent.definition_ai_kid || '思考中...',
        tags: aiContent.tags || []
      },
      assets: {
        image_url: imageUrl
      }
    }

    console.log("✅ 最终响应结构:")
    console.log(JSON.stringify(wordData, null, 2))
    console.log("")
    console.log("🎉 函数逻辑测试通过!")

    return true
  } catch (error) {
    console.error("❌ 测试失败:", error)
    return false
  }
}

testFunction()


