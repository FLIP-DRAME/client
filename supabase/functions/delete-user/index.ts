import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing Authorization' }), {
      status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  // Verify caller via JWT
  const anonClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    { global: { headers: { Authorization: authHeader } } },
  )
  const { data: { user }, error: authError } = await anonClient.auth.getUser()
  if (authError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const uid = user.id

  // Admin client bypasses RLS — can delete anything
  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  const errors: string[] = []
  const safe = async (label: string, fn: () => Promise<unknown>) => {
    try { await fn() } catch (e) { errors.push(`${label}: ${e}`) }
  }

  // 1. Get operator profile id (if operator)
  const { data: opRow } = await admin
    .from('operator_profiles').select('id').eq('user_id', uid).maybeSingle()
  const operatorId: string | null = opRow?.id ?? null

  if (operatorId) {
    // Portfolio
    const { data: items } = await admin.from('portfolio_items').select('id').eq('operator_id', operatorId)
    for (const item of items ?? []) {
      await safe('portfolio_assets', () => admin.from('portfolio_assets').delete().eq('item_id', item.id))
    }
    await safe('portfolio_items', () => admin.from('portfolio_items').delete().eq('operator_id', operatorId))

    // Feed
    const { data: posts } = await admin.from('feed_posts').select('id').eq('operator_id', operatorId)
    for (const post of posts ?? []) {
      await safe('feed_post_assets', () => admin.from('feed_post_assets').delete().eq('post_id', post.id))
      await safe('feed_likes(post)', () => admin.from('feed_likes').delete().eq('post_id', post.id))
      await safe('feed_comments(post)', () => admin.from('feed_comments').delete().eq('post_id', post.id))
    }
    await safe('feed_posts', () => admin.from('feed_posts').delete().eq('operator_id', operatorId))

    // Operator quotes → payments first
    const { data: opQuotes } = await admin.from('quotes').select('id').eq('operator_id', operatorId)
    for (const q of opQuotes ?? []) {
      await safe('payments(op_quote)', () => admin.from('payments').delete().eq('quote_id', q.id))
    }
    await safe('quotes(operator)', () => admin.from('quotes').delete().eq('operator_id', operatorId))

    await safe('operator_licenses', () => admin.from('operator_licenses').delete().eq('operator_id', operatorId))
    await safe('operator_insurances', () => admin.from('operator_insurances').delete().eq('operator_id', operatorId))
    await safe('operator_drones', () => admin.from('operator_drones').delete().eq('operator_id', operatorId))
    await safe('operator_categories', () => admin.from('operator_categories').delete().eq('operator_id', operatorId))
    await safe('operator_service_areas', () => admin.from('operator_service_areas').delete().eq('operator_id', operatorId))
    await safe('operator_request_unlocks', () => admin.from('operator_request_unlocks').delete().eq('operator_user_id', uid))
    await safe('operator_profiles', () => admin.from('operator_profiles').delete().eq('user_id', uid))
  }

  // 2. User interactions
  await safe('feed_likes(user)', () => admin.from('feed_likes').delete().eq('user_id', uid))
  await safe('feed_comments(user)', () => admin.from('feed_comments').delete().eq('user_id', uid))

  // 3. Job requests — payments → quotes → job_requests
  const { data: reqs } = await admin.from('job_requests').select('id').eq('client_id', uid)
  for (const req of reqs ?? []) {
    const { data: quotes } = await admin.from('quotes').select('id').eq('job_request_id', req.id)
    for (const q of quotes ?? []) {
      await safe('payments(req_quote)', () => admin.from('payments').delete().eq('quote_id', q.id))
    }
    await safe('quotes(job_request)', () => admin.from('quotes').delete().eq('job_request_id', req.id))
  }
  await safe('job_requests', () => admin.from('job_requests').delete().eq('client_id', uid))

  // 4. Common user data
  await safe('user_push_tokens', () => admin.from('user_push_tokens').delete().eq('user_id', uid))
  await safe('notifications', () => admin.from('notifications').delete().eq('recipient_id', uid))
  await safe('profiles', () => admin.from('profiles').delete().eq('id', uid))

  // 5. Delete auth user
  const { error: deleteError } = await admin.auth.admin.deleteUser(uid)
  if (deleteError) {
    return new Response(JSON.stringify({ error: `auth delete failed: ${deleteError.message}`, soft_errors: errors }), {
      status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  return new Response(JSON.stringify({ success: true, soft_errors: errors }), {
    status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  })
})
