create extension if not exists "pgcrypto";
create extension if not exists "postgis";

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, role, email, name, nickname)
  values (
    new.id,
    coalesce((new.raw_user_meta_data ->> 'role')::public.user_role, 'client'),
    coalesce(new.email, ''),
    new.raw_user_meta_data ->> 'name',
    new.raw_user_meta_data ->> 'nickname'
  )
  on conflict (id) do update set
    email = excluded.email,
    name = excluded.name,
    nickname = excluded.nickname,
    role = excluded.role;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

drop policy if exists "users insert own profile" on public.profiles;
create policy "users insert own profile" on public.profiles
for insert with check (auth.uid() = id);

drop policy if exists "operators insert own licenses" on public.operator_licenses;
create policy "operators insert own licenses" on public.operator_licenses
for insert with check (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators insert own insurances" on public.operator_insurances;
create policy "operators insert own insurances" on public.operator_insurances
for insert with check (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators insert own drones" on public.operator_drones;
create policy "operators insert own drones" on public.operator_drones
for insert with check (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

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

grant execute on function public.is_operator_profile_owner(uuid) to authenticated;

drop policy if exists "operators manage own categories" on public.operator_categories;
create policy "operators manage own categories" on public.operator_categories
for all using (public.is_operator_profile_owner(operator_id))
with check (public.is_operator_profile_owner(operator_id));

drop policy if exists "operators manage own service areas" on public.operator_service_areas;
create policy "operators manage own service areas" on public.operator_service_areas
for all using (public.is_operator_profile_owner(operator_id))
with check (public.is_operator_profile_owner(operator_id));

drop policy if exists "operators read own private licenses" on public.operator_licenses;
create policy "operators read own private licenses" on public.operator_licenses
for select using (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators read own private insurances" on public.operator_insurances;
create policy "operators read own private insurances" on public.operator_insurances
for select using (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators read own drones" on public.operator_drones;
create policy "operators read own drones" on public.operator_drones
for select using (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators read assigned job requests" on public.job_requests;
create policy "operators read assigned job requests" on public.job_requests
for select using (
  preferred_operator_id in (
    select op.id from public.operator_profiles op where op.user_id = auth.uid()
  )
);

drop policy if exists "operators manage own portfolio items" on public.portfolio_items;
create policy "operators manage own portfolio items" on public.portfolio_items
for all using (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators manage own portfolio assets" on public.portfolio_assets;
create policy "operators manage own portfolio assets" on public.portfolio_assets
for all using (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
) with check (
  exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators manage own feed posts" on public.feed_posts;
create policy "operators manage own feed posts" on public.feed_posts
for all using (
  author_id = auth.uid()
  or exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
) with check (
  author_id = auth.uid()
  or exists (
    select 1 from public.operator_profiles op
    where op.id = operator_id and op.user_id = auth.uid()
  )
);

drop policy if exists "operators manage own feed assets" on public.feed_post_assets;
create policy "operators manage own feed assets" on public.feed_post_assets
for all using (
  exists (
    select 1
    from public.feed_posts fp
    left join public.operator_profiles op on op.id = fp.operator_id
    where fp.id = post_id
      and (fp.author_id = auth.uid() or op.user_id = auth.uid())
  )
) with check (
  exists (
    select 1
    from public.feed_posts fp
    left join public.operator_profiles op on op.id = fp.operator_id
    where fp.id = post_id
      and (fp.author_id = auth.uid() or op.user_id = auth.uid())
  )
);

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

insert into public.operator_categories (operator_id, category_id)
select op.id, sc.id
from public.operator_profiles op
cross join public.service_categories sc
where op.status = 'approved'
  and not exists (
    select 1
    from public.operator_categories oc
    where oc.operator_id = op.id
  )
on conflict do nothing;

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

insert into public.operator_service_areas (operator_id, region_id, permission_type)
select op.id, r.id, 'available'::public.area_permission_type
from public.operator_profiles op
cross join public.regions r
where op.status = 'approved'
  and r.level = 1
  and not exists (
    select 1
    from public.operator_service_areas osa
    where osa.operator_id = op.id
  )
on conflict do nothing;
