-- RPC: delete_user
-- Owned by supabase_auth_admin so it can DELETE from auth.users.
create or replace function public.delete_user()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  _uid uuid := auth.uid();
begin
  if _uid is null then
    raise exception 'Not authenticated';
  end if;
  delete from auth.users where id = _uid;
end;
$$;

-- KEY: transfer ownership so SECURITY DEFINER runs as supabase_auth_admin
-- which has DELETE privilege on auth.users
alter function public.delete_user() owner to supabase_auth_admin;

revoke all on function public.delete_user() from public;
grant execute on function public.delete_user() to authenticated;
