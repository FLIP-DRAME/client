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

// FCM v1: create signed JWT → exchange for OAuth2 access token
async function getFcmAccessToken(serviceAccount: {
  client_email: string
  private_key: string
}): Promise<string> {
  const now = Math.floor(Date.now() / 1000)
  const header = { alg: 'RS256', typ: 'JWT' }
  const payload = {
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
    scope: 'https://www.googleapis.com/auth/firebase.messaging',
  }

  const enc = (obj: unknown) =>
    btoa(JSON.stringify(obj)).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')

  const signingInput = `${enc(header)}.${enc(payload)}`

  const keyPem = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '')

  const keyData = Uint8Array.from(atob(keyPem), (c) => c.charCodeAt(0))
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    keyData,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  )

  const jwt = `${signingInput}.${btoa(String.fromCharCode(...new Uint8Array(signature)))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '')}`

  const tokenRes = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwt,
    }),
  })
  const { access_token } = await tokenRes.json()
  return access_token as string
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

  const serviceAccountJson = Deno.env.get('FCM_SERVICE_ACCOUNT')!
  const serviceAccount = JSON.parse(serviceAccountJson)
  const projectId = serviceAccount.project_id

  const accessToken = await getFcmAccessToken(serviceAccount)

  const fcmRes = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${accessToken}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        message: {
          token: tokenRow.fcm_token,
          notification: { title, body },
          data: { kind: payload.record.kind },
          apns: {
            payload: {
              aps: { sound: 'default', badge: 1 },
            },
          },
        },
      }),
    },
  )

  const result = await fcmRes.json()
  return new Response(JSON.stringify(result), {
    status: fcmRes.ok ? 200 : 500,
    headers: { 'Content-Type': 'application/json' },
  })
})
