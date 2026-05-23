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

-- helper macro repeated for each table ──────────────────────

-- operator_licenses
drop policy if exists "operators manage own licenses"    on public.operator_licenses;
drop policy if exists "public read operator licenses"    on public.operator_licenses;
create policy "operators manage own licenses" on public.operator_licenses
  for all to authenticated
  using   (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()))
  with check (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()));
create policy "public read operator licenses" on public.operator_licenses
  for select using (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.status = 'approved'));

-- operator_insurances
drop policy if exists "operators manage own insurances"  on public.operator_insurances;
drop policy if exists "public read operator insurances"  on public.operator_insurances;
create policy "operators manage own insurances" on public.operator_insurances
  for all to authenticated
  using   (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()))
  with check (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()));
create policy "public read operator insurances" on public.operator_insurances
  for select using (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.status = 'approved'));

-- operator_drones
drop policy if exists "operators manage own drones"      on public.operator_drones;
drop policy if exists "public read operator drones"      on public.operator_drones;
create policy "operators manage own drones" on public.operator_drones
  for all to authenticated
  using   (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()))
  with check (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()));
create policy "public read operator drones" on public.operator_drones
  for select using (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.status = 'approved'));

-- operator_service_areas
drop policy if exists "operators manage own service areas" on public.operator_service_areas;
drop policy if exists "public read operator service areas" on public.operator_service_areas;
create policy "operators manage own service areas" on public.operator_service_areas
  for all to authenticated
  using   (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()))
  with check (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()));
create policy "public read operator service areas" on public.operator_service_areas
  for select using (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.status = 'approved'));

-- operator_categories
drop policy if exists "operators manage own categories"  on public.operator_categories;
drop policy if exists "public read operator categories"  on public.operator_categories;
create policy "operators manage own categories" on public.operator_categories
  for all to authenticated
  using   (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()))
  with check (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.user_id = auth.uid()));
create policy "public read operator categories" on public.operator_categories
  for select using (exists (select 1 from public.operator_profiles op where op.id = operator_id and op.status = 'approved'));

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
