import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENROUTER_API_KEY = Deno.env.get('OPENROUTER_API_KEY')
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
    const { wordIds, theme } = await req.json()

    if (!wordIds || !Array.isArray(wordIds) || wordIds.length === 0) {
      return new Response(
        JSON.stringify({ error: 'wordIds array is required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    if (!OPENROUTER_API_KEY) {
      return new Response(
        JSON.stringify({ error: 'OPENROUTER_API_KEY is not configured' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Fetch words from database
    let words: string[] = []
    if (SUPABASE_URL && SUPABASE_SERVICE_ROLE_KEY) {
      const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
      const { data: wordsData, error } = await supabase
        .from('words')
        .select('word')
        .in('id', wordIds)

      if (error) {
        console.error('Database error:', error)
      } else {
        words = wordsData.map(w => w.word)
      }
    }

    if (words.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No words found' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Call OpenRouter API (supports multiple LLMs including DeepSeek)
    const openrouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://my-ai-vocab-app.com',
        'X-Title': 'AI Kids Vocab App',
      },
      body: JSON.stringify({
        model: 'deepseek/deepseek-chat', // Using DeepSeek via OpenRouter
        messages: [
          {
            role: 'system',
            content: 'You are a creative children\'s story writer. Create engaging, educational stories that incorporate the given words naturally. The stories should be fun, age-appropriate, and help children learn vocabulary.'
          },
          {
            role: 'user',
            content: `Create a ${theme || 'fun and adventurous'} story for children that naturally incorporates these words: ${words.join(', ')}. 
            The story should be 200-300 words, engaging, and help children understand the meaning of these words through context. 
            Format the story in markdown with proper paragraphs.`
          }
        ],
        temperature: 0.8,
        max_tokens: 500,
      }),
    })

    if (!openrouterResponse.ok) {
      const error = await openrouterResponse.text()
      console.error('OpenRouter API error:', error)
      return new Response(
        JSON.stringify({ error: 'Failed to generate story' }),
        { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const openrouterData = await openrouterResponse.json()
    const story = openrouterData.choices[0]?.message?.content || 'Unable to generate story.'

    return new Response(
      JSON.stringify({ story, words }),
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

