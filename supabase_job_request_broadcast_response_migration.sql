-- Fix: an operator who responds to a broadcast (map-posted) job request --
-- one with preferred_operator_id null -- currently can never see it again,
-- and the app's status update after quoting silently no-ops, because the
-- existing SELECT/UPDATE RLS policies on job_requests only match rows where
-- preferred_operator_id = the operator's own id. Broadcast requests are
-- inserted with preferred_operator_id null, so they never match.
--
-- Confirmed live via direct REST calls as an operator test account:
--   - SELECT on a broadcast job_requests row -> [] (0 rows), even after
--     inserting a matching `quotes` row for that operator.
--   - UPDATE job_requests.status on that same row -> [] (0 rows affected),
--     confirmed unchanged via job_requests_map_public afterwards.
-- Both are RLS silently dropping the row, not app-level bugs.
--
-- These are additive PERMISSIVE policies (Postgres ORs multiple permissive
-- policies for the same command together), so they only ADD visibility for
-- rows the operator has already quoted -- broadcast requests an operator
-- hasn't responded to yet remain invisible via the base table, same as
-- before. Browsing unclaimed broadcast requests still goes through the
-- privacy-safe job_requests_map_public view, unaffected by this migration.
--
-- REVISION 2 (2026-07-04): the first version of this migration put the
-- quotes/operator_profiles lookup directly inline in the USING clause. That
-- caused `42P17: infinite recursion detected in policy for relation
-- "job_requests"` for EVERY authenticated query against job_requests
-- (confirmed live for both the client and operator test accounts) --
-- `quotes` apparently has its own RLS policy that queries job_requests,
-- so evaluating the two policies together cycles forever. Fixed by moving
-- the lookup into a SECURITY DEFINER function: its internal query runs as
-- the function owner (the role that executes this migration, normally the
-- Supabase admin/postgres role), which bypasses RLS on `quotes` by default
-- as the table owner, breaking the cycle. This is the same mechanism
-- `job_requests_map_public` (a plain, non-security-invoker view) already
-- relies on to read past job_requests' RLS for the public map -- see
-- supabase_job_request_map_migration.sql. This file is idempotent (DROP
-- POLICY IF EXISTS / CREATE OR REPLACE FUNCTION) -- safe to re-run even if
-- the broken revision 1 was already applied.
--
-- Run from Supabase SQL Editor.

create or replace function public.operator_has_quoted_request(p_job_request_id uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1
    from quotes q
    join operator_profiles op on op.id = q.operator_id
    where q.job_request_id = p_job_request_id
      and op.user_id = auth.uid()
  );
$$;

revoke all on function public.operator_has_quoted_request(uuid) from public;
grant execute on function public.operator_has_quoted_request(uuid) to authenticated;

drop policy if exists "operators can view job requests they have quoted" on public.job_requests;
create policy "operators can view job requests they have quoted"
  on public.job_requests
  for select
  to authenticated
  using ( public.operator_has_quoted_request(job_requests.id) );

drop policy if exists "operators can update job requests they have quoted" on public.job_requests;
create policy "operators can update job requests they have quoted"
  on public.job_requests
  for update
  to authenticated
  using ( public.operator_has_quoted_request(job_requests.id) )
  with check ( public.operator_has_quoted_request(job_requests.id) );
