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
            content: 'You are a helpful assistant that creates educational content for children learning English vocabulary. Provide word definitions in both Chinese and English, examples, and fun facts in a child-friendly way. Ensure definitions are accurate and precise, referencing standard dictionaries like Oxford, Cambridge, or Merriam-Webster. Include important details like who uses the word or in what context. Support multiple parts of speech.'
          },
          {
            role: 'user',
            content: `Explain "${word}" for a kid (8-12). 
Return JSON:
{
  "definition_zh": "Chinese meaning",
  "definition_en_simple": "Simple English definition",
  "definition_ai_kid": "Fun analogy starting with 'Imagine...'",
  "part_of_speech": "Part of speech (e.g. noun, verb, interjection)", 
  "phonetic_us": "US IPA phonetic (e.g. /hai/)", 
  "phonetic_uk": "UK IPA phonetic (e.g. /hai/)",
  "tags": ["tag1", "tag2"]
}`
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
        part_of_speech: 'word',
        phonetic_us: '',
        phonetic_uk: '',
        tags: [],
        image_url: ''
      }
    }

    // Generate image URL using free Pollinations.ai API
    // Create a realistic image prompt based on the word's actual meaning
    const targetWord = word.toLowerCase()
    
    // Build a more accurate image prompt from the AI-generated content
    let imagePrompt = targetWord
    
    if (aiContent.definition_en_simple) {
      const simpleDef = aiContent.definition_en_simple.toLowerCase()
      
      // Comprehensive stop words list
      const stopWords = new Set([
        'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
        'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'should',
        'can', 'could', 'may', 'might', 'must', 'shall', 'that', 'this',
        'these', 'those', 'with', 'for', 'and', 'or', 'but', 'to', 'of',
        'in', 'on', 'at', 'by', 'from', 'as', 'it', 'its', 'they', 'them',
        'used', 'typically', 'usually', 'often', 'sometimes', 'generally',
        'expression', 'word', 'term', 'means', 'meaning', 'refers', 'called'
      ])
      
      // Extract meaningful words (nouns, verbs, adjectives) from definition
      const words = simpleDef
        .replace(/[^\w\s]/g, ' ') // Remove punctuation
        .split(/\s+/)
        .filter(w => w.length > 3 && !stopWords.has(w))
        .slice(0, 5) // Take first 5 meaningful words
      
      if (words.length > 0) {
        // Create a descriptive prompt based on the word's meaning
        imagePrompt = `${targetWord}, ${words.join(', ')}, realistic, high quality, detailed, photograph`
      } else {
        // Fallback: use word with descriptive context based on part of speech
        const partOfSpeech = aiContent.part_of_speech?.toLowerCase() || ''
        if (partOfSpeech.includes('verb')) {
          imagePrompt = `${targetWord} action, realistic, high quality, detailed, photograph`
        } else if (partOfSpeech.includes('noun')) {
          imagePrompt = `${targetWord} object, realistic, high quality, detailed, photograph`
        } else if (partOfSpeech.includes('adjective')) {
          imagePrompt = `${targetWord} quality, realistic, high quality, detailed, photograph`
        } else if (partOfSpeech.includes('interjection') || partOfSpeech.includes('greeting')) {
          // Special handling for greetings like "hi"
          imagePrompt = `friendly greeting, waving hand, smiling person, realistic, high quality, detailed, photograph`
        } else {
          imagePrompt = `${targetWord}, realistic, high quality, detailed, photograph`
        }
      }
    } else {
      imagePrompt = `${targetWord}, realistic, high quality, detailed, photograph`
    }
    
    const imageUrl = `https://image.pollinations.ai/prompt/${encodeURIComponent(imagePrompt)}?width=1024&height=1024&model=flux&enhance=true`

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
