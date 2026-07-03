-- Add shoot-location coordinates to feed_posts so the map feed can plot real
-- posts instead of mock pins. This is the *photo's* shoot location, picked by
-- the operator on a map or via place search at upload time -- not the
-- uploader's device GPS, which would be the wrong coordinate.
--
-- Run from Supabase SQL Editor.

alter table public.feed_posts
  add column if not exists latitude double precision,
  add column if not exists longitude double precision;

-- Keep values sane (Nominatim / map-tap coordinates should always be valid,
-- but guard against bad client input regardless).
alter table public.feed_posts drop constraint if exists feed_posts_latitude_range;
alter table public.feed_posts drop constraint if exists feed_posts_longitude_range;
alter table public.feed_posts
  add constraint feed_posts_latitude_range
    check (latitude is null or latitude between -90 and 90),
  add constraint feed_posts_longitude_range
    check (longitude is null or longitude between -180 and 180);

-- Speeds up "published posts that have a map pin" queries for the feed map.
create index if not exists idx_feed_posts_published_created_geotagged
  on public.feed_posts (is_published, created_at desc)
  where latitude is not null and longitude is not null;
