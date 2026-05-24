import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: {
    id: string
    recipient_id: string
    title: string
    body: string
    kind: string
  }
}

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json()

  if (payload.type !== 'INSERT' || payload.table !== 'notifications') {
    return new Response('ignored', { status: 200 })
  }

  const { recipient_id, title, body } = payload.record

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
  )

  const { data: tokenRow } = await supabase
    .from('user_push_tokens')
    .select('fcm_token')
    .eq('user_id', recipient_id)
    .maybeSingle()

  if (!tokenRow?.fcm_token) {
    return new Response('no token', { status: 200 })
  }

  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY')!

  const fcmRes = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      Authorization: `key=${fcmServerKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      to: tokenRow.fcm_token,
      notification: { title, body },
      data: { kind: payload.record.kind },
    }),
  })

  const result = await fcmRes.json()
  return new Response(JSON.stringify(result), {
    status: fcmRes.ok ? 200 : 500,
    headers: { 'Content-Type': 'application/json' },
  })
})
