import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const DEEPSEEK_API_KEY = Deno.env.get('DEEPSEEK_API_KEY')
// Supabase automatically provides these via Deno.env
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || Deno.env.get('SUPABASE_PROJECT_URL') || ''
const SERVICE_ROLE_KEY = Deno.env.get('SERVICE_ROLE_KEY') || ''

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
      console.error('DEEPSEEK_API_KEY is not configured')
      return new Response(
        JSON.stringify({ error: 'DEEPSEEK_API_KEY is not configured. Please set it in Supabase Secrets.' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Call DeepSeek API via ProbeX proxy
    const deepseekResponse = await fetch('https://api.probex.top/v1/chat/completions', {
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
            content: 'You are a helpful assistant that creates educational content for children learning English vocabulary. Provide ACCURATE word definitions based on standard dictionaries (Oxford, Cambridge, Merriam-Webster). Definitions must be precise and correct. Provide word definitions in both Chinese and English, examples, and fun facts in a child-friendly way.'
          },
          {
            role: 'user',
            content: `Provide ACCURATE dictionary definition for "${word}". Use standard dictionary definitions (Oxford, Cambridge, Merriam-Webster) as reference. Be precise and correct.

Return JSON:

{
  "definition_zh": "Accurate Chinese translation based on standard dictionary",
  "definition_en_simple": "ACCURATE English definition matching standard dictionaries (be precise, include key details like who uses it, what it's used for, etc.)",
  "definition_ai_kid": "Fun, child-friendly explanation starting with 'Imagine...' that helps kids remember the word",
  "part_of_speech": "Part of speech (e.g. noun, verb, adjective). If multiple, list them separated by comma",
  "phonetic_us": "US IPA phonetic transcription (e.g. /ˈdʒɪmi/)",
  "phonetic_uk": "UK IPA phonetic transcription (e.g. /ˈdʒɪmi/)",
  "tags": ["relevant", "tags"]
}

IMPORTANT: The definition_en_simple must be ACCURATE and match standard dictionary definitions. Include important details like who uses the word, in what context, etc.`
          }
        ],
        temperature: 0.7,
        max_tokens: 400,
      }),
    })

    if (!deepseekResponse.ok) {
      const errorText = await deepseekResponse.text()
      console.error('DeepSeek API error:', errorText)
      let errorMessage = 'Failed to generate word information'
      try {
        const errorJson = JSON.parse(errorText)
        errorMessage = errorJson.error?.message || errorText
      } catch (e) {
        errorMessage = errorText || 'Unknown error'
      }
      return new Response(
        JSON.stringify({ 
          error: errorMessage,
          details: 'DeepSeek API call failed. Check logs for more information.'
        }),
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

    // Generate image URL with multiple fallback options for better reliability
    const targetWord = word.toLowerCase()
    
    // Strategy: Generate multiple image URL options
    // The frontend can try them in order if one fails
    
    // Option 1: Pollinations.ai - simple format (most compatible)
    const imageUrl1 = `https://image.pollinations.ai/prompt/${encodeURIComponent(targetWord)}?width=1024&height=1024`
    
    // Option 2: Pollinations.ai - with realistic modifier (better quality when it works)
    const imageUrl2 = `https://image.pollinations.ai/prompt/${encodeURIComponent(targetWord + ' realistic photograph')}?width=1024&height=1024`
    
    // Option 3: Use a placeholder service as ultimate fallback
    // This ensures there's always an image URL, even if generation fails
    const fallbackUrl = `https://via.placeholder.com/1024x1024/4A90E2/FFFFFF?text=${encodeURIComponent(targetWord.toUpperCase())}`
    
    // For now, use the simple format as primary
    // Frontend can implement retry logic with imageUrl2 as fallback
    const imageUrl = imageUrl1

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
        part_of_speech: aiContent.part_of_speech || 'word',
        phonetic_us: aiContent.phonetic_us || '',
        phonetic_uk: aiContent.phonetic_uk || '',
        tags: aiContent.tags || []
      },
      assets: {
        image_url: imageUrl  // Use free Pollinations.ai generated image
      }
    }

    // Save to Supabase database if configured
    if (SUPABASE_URL && SERVICE_ROLE_KEY) {
      const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY)
      
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

