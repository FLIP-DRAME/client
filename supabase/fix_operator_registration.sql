-- ============================================================
-- Fix: RLS policies + missing profile rows
--
-- Errors fixed:
--   42501  new row violates row-level security policy for table "profiles"
--   42501  new row violates row-level security policy for table "feed_posts"
--   23503  operator_profiles_user_id_fkey (Key is not present in table "profiles")
--
-- feed_posts policy simplified: INSERT uses only author_id = auth.uid()
-- (no subquery dependency on operator_profiles) to avoid 42501 on INSERT.
--
-- Apply in Supabase Dashboard → SQL Editor → Run
-- ============================================================

-- ─── PART 1: profiles RLS ────────────────────────────────────

-- INSERT: 자기 자신 행만 추가 가능
drop policy if exists "users insert own profile" on public.profiles;
create policy "users insert own profile" on public.profiles
  for insert with check (auth.uid() = id);

-- UPDATE: upsert 가 ON CONFLICT 시 UPDATE 를 실행하므로 반드시 필요
drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile" on public.profiles
  for update using (auth.uid() = id)
  with check (auth.uid() = id);

-- SELECT: 자기 프로필 읽기 허용
drop policy if exists "users read own profile" on public.profiles;
create policy "users read own profile" on public.profiles
  for select using (auth.uid() = id);

-- ─── PART 2: operator_profiles RLS ──────────────────────────

-- INSERT: 본인 user_id 로만 등록 가능
drop policy if exists "operators insert own operator profile" on public.operator_profiles;
create policy "operators insert own operator profile" on public.operator_profiles
  for insert with check (auth.uid() = user_id);

-- UPDATE: upsert ON CONFLICT 처리용
drop policy if exists "operators update own operator profile" on public.operator_profiles;
create policy "operators update own operator profile" on public.operator_profiles
  for update using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- SELECT: 승인된 운용자는 공개 열람, 본인은 항상 읽기 가능
--   feed_posts with check 의 subquery 도 이 정책을 사용함
drop policy if exists "public read approved operator profiles" on public.operator_profiles;
create policy "public read approved operator profiles" on public.operator_profiles
  for select using (
    status = 'approved'
    or auth.uid() = user_id
  );

-- ─── PART 3: feed_posts RLS ──────────────────────────────────

-- Enable RLS (idempotent)
alter table public.feed_posts enable row level security;
alter table public.operator_profiles enable row level security;
alter table public.profiles enable row level security;
alter table public.feed_post_assets enable row level security;

-- Drop ALL existing feed_posts policies to start clean
drop policy if exists "operators manage own feed posts" on public.feed_posts;
drop policy if exists "public read published feed posts" on public.feed_posts;
drop policy if exists "feed_posts insert own" on public.feed_posts;
drop policy if exists "feed_posts manage own" on public.feed_posts;
drop policy if exists "feed_posts update own" on public.feed_posts;
drop policy if exists "feed_posts delete own" on public.feed_posts;
drop policy if exists "feed_posts select public" on public.feed_posts;

-- INSERT: only check author_id = current user (no subquery dependency)
create policy "feed_posts insert own" on public.feed_posts
  for insert
  to authenticated
  with check (author_id = auth.uid());

-- UPDATE/DELETE: operator manages their own posts
create policy "feed_posts manage own" on public.feed_posts
  for all
  to authenticated
  using (author_id = auth.uid())
  with check (author_id = auth.uid());

-- SELECT: published posts are public; own posts always readable
create policy "feed_posts select public" on public.feed_posts
  for select
  using (is_published = true or author_id = auth.uid());

-- feed_post_assets: follow the parent post's author
drop policy if exists "operators manage own feed assets" on public.feed_post_assets;
drop policy if exists "feed_post_assets manage own" on public.feed_post_assets;
drop policy if exists "feed_post_assets select public" on public.feed_post_assets;

create policy "feed_post_assets manage own" on public.feed_post_assets
  for all
  to authenticated
  using (
    exists (
      select 1 from public.feed_posts fp
      where fp.id = post_id and fp.author_id = auth.uid()
    )
  )
  with check (
    exists (
      select 1 from public.feed_posts fp
      where fp.id = post_id and fp.author_id = auth.uid()
    )
  );

create policy "feed_post_assets select public" on public.feed_post_assets
  for select
  using (
    exists (
      select 1 from public.feed_posts fp
      where fp.id = post_id and fp.is_published = true
    )
  );

-- ─── PART 4: operator sub-table RLS ─────────────────────────
-- operator_licenses / operator_insurances / operator_drones / operator_service_areas
-- These all have an operator_id FK → operator_profiles.id.
-- Ownership check: operator_profiles.user_id = auth.uid()

alter table public.operator_licenses    enable row level security;
alter table public.operator_insurances  enable row level security;
alter table public.operator_drones      enable row level security;
alter table public.operator_service_areas enable row level security;
alter table public.operator_categories  enable row level security;

-- RLS policy helpers.
-- Sub-table policies need to check operator_profiles ownership. In some
-- projects, existing operator_profiles SELECT policies can make that lookup
-- invisible inside another table's RLS check. SECURITY DEFINER keeps the
-- ownership check tied to auth.uid(), but avoids that policy recursion/visibility
-- problem.
create or replace function public.is_operator_profile_owner(operator_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.operator_profiles op
    where op.id = operator_profile_id
      and op.user_id = auth.uid()
  );
$$;

create or replace function public.is_operator_profile_approved(operator_profile_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.operator_profiles op
    where op.id = operator_profile_id
      and op.status = 'approved'
  );
$$;

grant execute on function public.is_operator_profile_owner(uuid) to authenticated;
grant execute on function public.is_operator_profile_approved(uuid) to anon, authenticated;

-- ─── Notifications ──────────────────────────────────────────

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  kind text not null default 'general',
  title text not null,
  body text not null default '',
  source_table text,
  source_id uuid,
  dedupe_key text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

alter table public.operator_profiles
  alter column status set default 'pending_review';

alter table public.notifications
  add column if not exists source_table text,
  add column if not exists source_id uuid,
  add column if not exists dedupe_key text;

create unique index if not exists notifications_dedupe_key_idx
  on public.notifications (dedupe_key);

create index if not exists notifications_recipient_unread_idx
  on public.notifications (recipient_id, read_at, created_at desc);

alter table public.notifications enable row level security;

drop policy if exists "users read own notifications" on public.notifications;
create policy "users read own notifications" on public.notifications
  for select to authenticated
  using (recipient_id = auth.uid());

drop policy if exists "users update own notifications" on public.notifications;
create policy "users update own notifications" on public.notifications
  for update to authenticated
  using (recipient_id = auth.uid())
  with check (recipient_id = auth.uid());

drop policy if exists "participants create notifications" on public.notifications;
create policy "participants create notifications" on public.notifications
  for insert to authenticated
  with check (true);

create or replace function public.notify_operator_on_job_request()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  operator_user_id uuid;
  category_label text;
begin
  if new.preferred_operator_id is null then
    return new;
  end if;

  select op.user_id into operator_user_id
  from public.operator_profiles op
  where op.id = new.preferred_operator_id;

  if operator_user_id is null then
    return new;
  end if;

  select sc.label into category_label
  from public.service_categories sc
  where sc.id = new.category_id;

  insert into public.notifications (
    recipient_id,
    kind,
    title,
    body,
    source_table,
    source_id,
    dedupe_key
  ) values (
    operator_user_id,
    'quote_request',
    '새 견적 요청이 도착했습니다',
    concat_ws(' ', coalesce(new.location_label, '요청'), coalesce(category_label, '드론 작업')) || ' 요청을 확인해 주세요.',
    'job_requests',
    new.id,
    'job_request:' || new.id::text || ':operator_request'
  )
  on conflict (dedupe_key) do nothing;

  return new;
end;
$$;

drop trigger if exists job_requests_notify_operator on public.job_requests;
create trigger job_requests_notify_operator
after insert on public.job_requests
for each row execute function public.notify_operator_on_job_request();

create or replace function public.notify_quote_status_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  client_user_id uuid;
  operator_user_id uuid;
  request_label text;
begin
  select jr.client_id, coalesce(jr.location_label, jr.title, '요청')
  into client_user_id, request_label
  from public.job_requests jr
  where jr.id = new.job_request_id;

  if new.status = 'submitted'
     and (tg_op = 'INSERT' or (tg_op = 'UPDATE' and old.status is distinct from new.status))
     and client_user_id is not null then
    insert into public.notifications (
      recipient_id,
      kind,
      title,
      body,
      source_table,
      source_id,
      dedupe_key
    ) values (
      client_user_id,
      'quote_received',
      '견적을 받았습니다',
      request_label || ' 견적이 도착했습니다.',
      'quotes',
      new.job_request_id,
      'job_request:' || new.job_request_id::text || ':client_quote_received'
    )
    on conflict (dedupe_key) do nothing;
  end if;

  if new.status = 'accepted'
     and (tg_op = 'INSERT' or (tg_op = 'UPDATE' and old.status is distinct from new.status)) then
    select op.user_id into operator_user_id
    from public.operator_profiles op
    where op.id = new.operator_id;

    if operator_user_id is not null then
      insert into public.notifications (
        recipient_id,
        kind,
        title,
        body,
        source_table,
        source_id,
        dedupe_key
      ) values (
        operator_user_id,
        'quote_accepted',
        '견적이 확정되었습니다',
        request_label || ' 요청의 견적이 확정되었습니다.',
        'quotes',
        new.id,
        'quote:' || new.id::text || ':operator_accepted'
      )
      on conflict (dedupe_key) do nothing;
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists quotes_notify_status_change on public.quotes;
create trigger quotes_notify_status_change
after insert or update of status on public.quotes
for each row execute function public.notify_quote_status_change();

-- helper macro repeated for each table ──────────────────────

-- operator_licenses
drop policy if exists "operators manage own licenses"    on public.operator_licenses;
drop policy if exists "public read operator licenses"    on public.operator_licenses;
create policy "operators manage own licenses" on public.operator_licenses
  for all to authenticated
  using   (public.is_operator_profile_owner(operator_id))
  with check (public.is_operator_profile_owner(operator_id));
create policy "public read operator licenses" on public.operator_licenses
  for select using (public.is_operator_profile_approved(operator_id));

-- operator_insurances
drop policy if exists "operators manage own insurances"  on public.operator_insurances;
drop policy if exists "public read operator insurances"  on public.operator_insurances;
create policy "operators manage own insurances" on public.operator_insurances
  for all to authenticated
  using   (public.is_operator_profile_owner(operator_id))
  with check (public.is_operator_profile_owner(operator_id));
create policy "public read operator insurances" on public.operator_insurances
  for select using (public.is_operator_profile_approved(operator_id));

-- operator_drones
drop policy if exists "operators manage own drones"      on public.operator_drones;
drop policy if exists "public read operator drones"      on public.operator_drones;
create policy "operators manage own drones" on public.operator_drones
  for all to authenticated
  using   (public.is_operator_profile_owner(operator_id))
  with check (public.is_operator_profile_owner(operator_id));
create policy "public read operator drones" on public.operator_drones
  for select using (public.is_operator_profile_approved(operator_id));

-- operator_service_areas
drop policy if exists "operators manage own service areas" on public.operator_service_areas;
drop policy if exists "public read operator service areas" on public.operator_service_areas;
create policy "operators manage own service areas" on public.operator_service_areas
  for all to authenticated
  using   (public.is_operator_profile_owner(operator_id))
  with check (public.is_operator_profile_owner(operator_id));
create policy "public read operator service areas" on public.operator_service_areas
  for select using (public.is_operator_profile_approved(operator_id));

-- operator_categories
drop policy if exists "operators manage own categories"  on public.operator_categories;
drop policy if exists "public read operator categories"  on public.operator_categories;
create policy "operators manage own categories" on public.operator_categories
  for all to authenticated
  using   (public.is_operator_profile_owner(operator_id))
  with check (public.is_operator_profile_owner(operator_id));
create policy "public read operator categories" on public.operator_categories
  for select using (public.is_operator_profile_approved(operator_id));

-- ─── PART 5: 기존 유저 profiles 행 backfill ─────────────────
-- 트리거 적용 전에 가입한 유저는 profiles 행이 없어 FK / 피드 INSERT 모두 실패함.
-- SQL Editor 는 postgres 권한으로 실행되므로 RLS 우회 가능.
-- ON CONFLICT DO NOTHING 으로 중복 실행해도 안전.
insert into public.profiles (id, role, email, name, nickname)
select
  au.id,
  case
    when au.raw_user_meta_data ->> 'role' = 'operator'
      then 'operator'::public.user_role
    else 'client'::public.user_role
  end                                                   as role,
  coalesce(au.email, '')                                as email,
  coalesce(au.raw_user_meta_data ->> 'name',     '')   as name,
  coalesce(au.raw_user_meta_data ->> 'nickname', '')   as nickname
from auth.users au
where not exists (
  select 1 from public.profiles p where p.id = au.id
)
on conflict (id) do nothing;

-- ─── PART 6: quote request / quote status RLS ───────────────

create or replace function public.is_job_request_client(job_request_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.job_requests jr
    where jr.id = job_request_id
      and jr.client_id = auth.uid()
  );
$$;

create or replace function public.is_job_request_operator(job_request_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.job_requests jr
    join public.operator_profiles op
      on op.id = jr.preferred_operator_id
    where jr.id = job_request_id
      and op.user_id = auth.uid()
  );
$$;

grant execute on function public.is_job_request_client(uuid) to authenticated;
grant execute on function public.is_job_request_operator(uuid) to authenticated;

alter table public.job_requests enable row level security;
alter table public.quotes enable row level security;

alter table public.job_requests
  add column if not exists operator_viewed_at timestamptz;

drop policy if exists "clients read own job requests" on public.job_requests;
drop policy if exists "clients insert own job requests" on public.job_requests;
drop policy if exists "clients update own job requests" on public.job_requests;
drop policy if exists "operators read assigned job requests" on public.job_requests;
drop policy if exists "operators update assigned job requests" on public.job_requests;

create policy "clients read own job requests" on public.job_requests
  for select to authenticated
  using (client_id = auth.uid());

create policy "clients insert own job requests" on public.job_requests
  for insert to authenticated
  with check (client_id = auth.uid());

create policy "clients update own job requests" on public.job_requests
  for update to authenticated
  using (client_id = auth.uid())
  with check (client_id = auth.uid());

create policy "operators read assigned job requests" on public.job_requests
  for select to authenticated
  using (public.is_operator_profile_owner(preferred_operator_id));

create policy "operators update assigned job requests" on public.job_requests
  for update to authenticated
  using (public.is_operator_profile_owner(preferred_operator_id))
  with check (public.is_operator_profile_owner(preferred_operator_id));

drop policy if exists "clients read quotes for own requests" on public.quotes;
drop policy if exists "operators manage own quotes" on public.quotes;

create policy "clients read quotes for own requests" on public.quotes
  for select to authenticated
  using (public.is_job_request_client(job_request_id));

create policy "operators manage own quotes" on public.quotes
  for all to authenticated
  using (public.is_operator_profile_owner(operator_id))
  with check (
    public.is_operator_profile_owner(operator_id)
    and public.is_job_request_operator(job_request_id)
  );
