import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const DEEPSEEK_API_KEY = Deno.env.get('DEEPSEEK_API_KEY')
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { word } = await req.json()

    if (!word || typeof word !== 'string') {
      return new Response(
        JSON.stringify({ error: 'Word parameter is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!DEEPSEEK_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'DEEPSEEK_API_KEY is not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Call DeepSeek API directly
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
      const error = await deepseekResponse.text()
      console.error('DeepSeek API error:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to generate word information' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const deepseekData = await deepseekResponse.json()
    const content = deepseekData.choices[0]?.message?.content || '{}'
    
    // Parse the JSON response from OpenAI
    let aiContent
    try {
      // Extract JSON from markdown code blocks if present
      const jsonMatch = content.match(/```json\s*([\s\S]*?)\s*```/) || content.match(/```\s*([\s\S]*?)\s*```/)
      const jsonString = jsonMatch ? jsonMatch[1] : content
      aiContent = JSON.parse(jsonString)
    } catch (e) {
      // If parsing fails, create a basic structure
      aiContent = {
        definition_zh: '暂无中文定义',
        definition_en_simple: content.substring(0, 200),
        definition_ai_kid: content.substring(0, 150),
        tags: [],
        image_url: ''
      }
    }

    // Generate image URL using free Pollinations.ai API
    // This is a free AI image generation API (no key needed, completely free!)
    const targetWord = word.toLowerCase()
    const imageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(targetWord)}%20cartoon%20cute?width=1024&height=1024`

    // Generate a unique ID for the word
    const wordId = crypto.randomUUID()

    // Format response to match Word model structure
    const wordData = {
      id: wordId,
      word: word.toLowerCase(),
      content: {
        definition_zh: aiContent.definition_zh || '暂无中文',
        definition_en_simple: aiContent.definition_en_simple || '',
        definition_ai_kid: aiContent.definition_ai_kid || '思考中...',
        tags: aiContent.tags || []
      },
      assets: {
        image_url: imageUrl  // Use free Pollinations.ai generated image
      }
    }

    // Save to Supabase database if configured
    if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
      
      try {
        // Check if word already exists
        const { data: existingWord } = await supabase
          .from('words')
          .select('id')
          .eq('word', word.toLowerCase())
          .maybeSingle()

        if (existingWord) {
          wordData.id = existingWord.id
        } else {
          // Insert new word (if your schema supports it)
          // Note: Adjust this based on your actual database schema
          const { data: newWord, error } = await supabase
            .from('words')
            .insert({
              id: wordId,
              word: word.toLowerCase(),
              content: wordData.content,
              assets: wordData.assets,
            })
            .select('id')
            .single()

          if (error) {
            console.error('Database error:', error)
          } else if (newWord) {
            wordData.id = newWord.id
          }
        }
      } catch (dbError) {
        console.error('Database operation error:', dbError)
        // Continue even if DB operation fails
      }
    }

    return new Response(
      JSON.stringify(wordData),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    )
  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

