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

-- Existing MVP registrations should become searchable immediately.
update public.operator_profiles
set status = 'approved'
where status = 'pending_review';

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
