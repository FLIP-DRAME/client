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
