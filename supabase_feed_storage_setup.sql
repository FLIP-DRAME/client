-- Feed image storage setup.
--
-- Run this once in Supabase SQL Editor before deploying the Storage-backed
-- feed image upload code. Images are stored in Storage, while
-- public.feed_post_assets.url stores only the public URL.

insert into storage.buckets (
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
)
values (
  'feed-assets',
  'feed-assets',
  true,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'feed assets are publicly readable'
  ) then
    create policy "feed assets are publicly readable"
      on storage.objects
      for select
      using (bucket_id = 'feed-assets');
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'users can upload own feed assets'
  ) then
    create policy "users can upload own feed assets"
      on storage.objects
      for insert
      to authenticated
      with check (
        bucket_id = 'feed-assets'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'users can update own feed assets'
  ) then
    create policy "users can update own feed assets"
      on storage.objects
      for update
      to authenticated
      using (
        bucket_id = 'feed-assets'
        and auth.uid()::text = (storage.foldername(name))[1]
      )
      with check (
        bucket_id = 'feed-assets'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'storage'
      and tablename = 'objects'
      and policyname = 'users can delete own feed assets'
  ) then
    create policy "users can delete own feed assets"
      on storage.objects
      for delete
      to authenticated
      using (
        bucket_id = 'feed-assets'
        and auth.uid()::text = (storage.foldername(name))[1]
      );
  end if;
end $$;
