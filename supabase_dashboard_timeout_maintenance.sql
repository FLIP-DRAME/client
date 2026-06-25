-- Supabase Dashboard "canceling statement due to statement timeout" maintenance.
--
-- The logs show Supabase Dashboard count-estimate queries timing out while
-- falling back to exact count(*) on these tables:
--   public.feed_post_assets
--   public.operator_reviews
--   public.operator_request_unlocks
--   public.operator_profiles
--
-- Run during low traffic from Supabase SQL Editor.
--
-- Supabase SQL Editor may wrap execution in a transaction. VACUUM cannot run
-- inside a transaction block, so this SQL intentionally uses CREATE INDEX and
-- ANALYZE only. If table bloat still needs manual VACUUM later, run VACUUM from
-- a direct psql session or a maintenance job outside the SQL Editor.

-- App query indexes for the tables involved in the timeout logs.
create index if not exists idx_feed_post_assets_post_sort
  on public.feed_post_assets (post_id, sort_order);

create index if not exists idx_operator_reviews_operator_created
  on public.operator_reviews (operator_id, created_at desc);

create index if not exists idx_operator_reviews_reviewer
  on public.operator_reviews (reviewer_id);

create index if not exists idx_operator_request_unlocks_operator_request
  on public.operator_request_unlocks (operator_user_id, job_request_id);

create index if not exists idx_operator_profiles_status_created
  on public.operator_profiles (status, created_at desc);

create index if not exists idx_operator_profiles_user_id
  on public.operator_profiles (user_id);

-- Neighboring feed/quote queries that join into the timed-out tables.
create index if not exists idx_feed_posts_operator_published_created
  on public.feed_posts (operator_id, is_published, created_at desc);

create index if not exists idx_feed_posts_published_created
  on public.feed_posts (is_published, created_at desc);

create index if not exists idx_feed_posts_author_created
  on public.feed_posts (author_id, created_at desc);

create index if not exists idx_feed_likes_post_user
  on public.feed_likes (post_id, user_id);

create index if not exists idx_feed_likes_user
  on public.feed_likes (user_id);

create index if not exists idx_job_requests_preferred_operator_created
  on public.job_requests (preferred_operator_id, created_at desc);

create index if not exists idx_job_requests_client_created
  on public.job_requests (client_id, created_at desc);

create index if not exists idx_quotes_job_request_operator
  on public.quotes (job_request_id, operator_id);

analyze public.feed_posts;
analyze public.feed_post_assets;
analyze public.feed_likes;
analyze public.operator_reviews;
analyze public.operator_request_unlocks;
analyze public.operator_profiles;
analyze public.job_requests;
analyze public.quotes;
