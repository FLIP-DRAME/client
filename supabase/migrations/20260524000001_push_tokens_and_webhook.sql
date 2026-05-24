-- user_push_tokens 테이블
create table if not exists public.user_push_tokens (
  user_id uuid primary key references auth.users(id) on delete cascade,
  fcm_token text not null,
  updated_at timestamptz not null default now()
);

alter table public.user_push_tokens enable row level security;

create policy "users can upsert own token"
  on public.user_push_tokens
  for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- pg_net 활성화 (이미 있으면 skip)
create extension if not exists pg_net with schema extensions;

-- notifications INSERT 시 Edge Function 호출 트리거
create or replace function public.trigger_push_notification()
returns trigger
language plpgsql
security definer
as $$
begin
  perform net.http_post(
    url     := 'https://wgujitwmipifuhxavmsn.supabase.co/functions/v1/send-push-notification',
    headers := jsonb_build_object(
      'Content-Type',  'application/json',
      'Authorization', 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndndWppdHdtaXBpZnVoeGF2bXNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxOTE1NzYsImV4cCI6MjA5Mzc2NzU3Nn0.hyT9OYf8MAmehOu9GEkaaYa_5QZMjH_3Nx3-yT9n61k'
    ),
    body    := jsonb_build_object(
      'type',       'INSERT',
      'table',      'notifications',
      'record',     to_jsonb(new),
      'schema',     'public',
      'old_record', null
    )
  );
  return new;
end;
$$;

drop trigger if exists on_notification_insert on public.notifications;

create trigger on_notification_insert
  after insert on public.notifications
  for each row
  execute function public.trigger_push_notification();
