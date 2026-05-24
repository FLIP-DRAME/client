-- FCM 토큰 저장 테이블
-- Supabase Dashboard > SQL Editor에서 실행하세요.

create table if not exists public.user_push_tokens (
  user_id uuid primary key references auth.users(id) on delete cascade,
  fcm_token text not null,
  updated_at timestamptz not null default now()
);

alter table public.user_push_tokens enable row level security;

-- 본인 토큰만 upsert 가능
create policy "users can upsert own token"
  on public.user_push_tokens
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- Edge Function(service role)이 토큰 조회 가능하도록 허용
-- (service_role은 RLS bypass하므로 별도 정책 불필요)
