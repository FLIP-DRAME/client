-- Chat rooms (one per job_request)
create table if not exists public.chat_rooms (
  id               uuid primary key default gen_random_uuid(),
  job_request_id   uuid not null references public.job_requests(id) on delete cascade,
  client_id        uuid not null references auth.users(id) on delete cascade,
  operator_id      uuid not null references auth.users(id) on delete cascade,
  last_message_at  timestamptz not null default now(),
  created_at       timestamptz not null default now(),
  constraint chat_rooms_job_request_unique unique(job_request_id)
);

alter table public.chat_rooms enable row level security;

create policy "participants can manage their rooms"
  on public.chat_rooms for all
  using  (auth.uid() = client_id or auth.uid() = operator_id)
  with check (auth.uid() = client_id or auth.uid() = operator_id);

-- Chat messages
create table if not exists public.chat_messages (
  id          uuid primary key default gen_random_uuid(),
  room_id     uuid not null references public.chat_rooms(id) on delete cascade,
  sender_id   uuid not null references auth.users(id) on delete cascade,
  content     text not null,
  is_read     boolean not null default false,
  created_at  timestamptz not null default now()
);

alter table public.chat_messages enable row level security;

create policy "room participants can manage messages"
  on public.chat_messages for all
  using (
    exists (
      select 1 from public.chat_rooms
      where id = room_id
        and (client_id = auth.uid() or operator_id = auth.uid())
    )
  )
  with check (
    sender_id = auth.uid() and
    exists (
      select 1 from public.chat_rooms
      where id = room_id
        and (client_id = auth.uid() or operator_id = auth.uid())
    )
  );

-- Update last_message_at when a new message is inserted
create or replace function public.update_chat_room_last_message_at()
returns trigger language plpgsql security definer as $$
begin
  update public.chat_rooms
  set last_message_at = new.created_at
  where id = new.room_id;
  return new;
end;
$$;

drop trigger if exists on_chat_message_insert on public.chat_messages;
create trigger on_chat_message_insert
  after insert on public.chat_messages
  for each row execute function public.update_chat_room_last_message_at();

-- Enable realtime for live message delivery
alter publication supabase_realtime add table public.chat_messages;
