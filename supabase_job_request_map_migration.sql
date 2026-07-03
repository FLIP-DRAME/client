-- Broadcast job-request map: lets a client post a request pinned on a map
-- (no specific preferred operator) and any registered operator can browse
-- + respond, mirroring the existing "받은 요청" flow.
--
-- Run from Supabase SQL Editor.

-- 1) A map-posted request has no single preferred operator (broadcast).
alter table public.job_requests
  alter column preferred_operator_id drop not null;

-- 2) Meet-up/shoot location for the request, picked on a map at creation
-- time (same idea as feed_posts.latitude/longitude).
alter table public.job_requests
  add column if not exists latitude double precision,
  add column if not exists longitude double precision;

alter table public.job_requests drop constraint if exists job_requests_latitude_range;
alter table public.job_requests drop constraint if exists job_requests_longitude_range;
alter table public.job_requests
  add constraint job_requests_latitude_range
    check (latitude is null or latitude between -90 and 90),
  add constraint job_requests_longitude_range
    check (longitude is null or longitude between -180 and 180);

create index if not exists idx_job_requests_open_geotagged
  on public.job_requests (status, created_at desc)
  where latitude is not null and longitude is not null;

-- 3) Public-safe view for the map: exposes only what's needed to render a
-- pin + preview card. Excludes contact_window/client_display_name/detail
-- so browsing the map never leaks a client's contact info or free-text
-- request body to operators who haven't opened/responded to it yet.
-- The view runs as its owner (not security_invoker), so it can read past
-- job_requests' RLS while only ever returning the safe column subset below.
drop view if exists public.job_requests_map_public;
create view public.job_requests_map_public as
select
  jr.id,
  jr.status,
  jr.budget_min,
  jr.budget_max,
  jr.latitude,
  jr.longitude,
  jr.location_label,
  jr.created_at,
  sc.label as category_label
from public.job_requests jr
left join public.service_categories sc on sc.id = jr.category_id
where jr.latitude is not null
  and jr.longitude is not null
  and jr.status not in ('draft', 'completed', 'cancelled');

grant select on public.job_requests_map_public to anon, authenticated;
