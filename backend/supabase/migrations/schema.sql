-- Radiguru Full Schema SQL
-- Generated: 2025-12-12T10:55:58.302410Z
-- Single-file schema that creates tables, indexes, RLS policies, functions, and triggers
-- Assumptions:
-- 1) Users can be doctors or normal users (role field).
-- 2) New accounts are public by default (private_account boolean default false).
-- 3) Storage buckets: avatars, posts, reels, stories (create these via supabase storage create-bucket)
-- Run this file in Supabase SQL editor or add as a migration and run via supabase CLI.

-- Enable required extensions
create extension if not exists "pgcrypto";
create extension if not exists "pg_trgm";

-- ###########################
-- 1) CORE: profiles & auth
-- ###########################

create table if not exists profiles (
  id uuid primary key default gen_random_uuid(),
  email text unique,
  username text unique,
  full_name text,
  role text default 'user', -- 'doctor' or 'user'
  bio text,
  specialization text,
  hospital_name text,
  avatar_url text,
  is_private boolean default false,
  notifications_enabled boolean default true,
  dark_mode boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create index if not exists profiles_username_trgm on profiles using gin (username gin_trgm_ops);
create index if not exists profiles_fullname_trgm on profiles using gin (full_name gin_trgm_ops);
create index if not exists profiles_specialization_trgm on profiles using gin (specialization gin_trgm_ops);

-- trigger to update updated_at
create or replace function trigger_set_timestamp()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger profiles_set_timestamp
before update on profiles
for each row execute procedure trigger_set_timestamp();

-- ###########################
-- 2) FOLLOWS
-- ###########################

create table if not exists follows (
  id bigserial primary key,
  follower_id uuid references profiles(id) on delete cascade,
  followed_id uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(follower_id, followed_id)
);

create index if not exists idx_follows_follower on follows(follower_id);
create index if not exists idx_follows_followed on follows(followed_id);

create table if not exists follow_requests (
  id bigserial primary key,
  requester_id uuid references profiles(id) on delete cascade,
  target_id uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(requester_id, target_id)
);

-- ###########################
-- 3) NOTIFICATIONS
-- ###########################

create table if not exists notifications (
  id uuid primary key default gen_random_uuid(),
  receiver_id uuid references profiles(id) on delete cascade,
  sender_id uuid references profiles(id),
  type text not null, -- like, comment, follow, message, follow_accepted, system
  read boolean default false,
  data jsonb,
  created_at timestamptz default now()
);

create index if not exists idx_notifications_receiver on notifications(receiver_id);

-- ###########################
-- 4) POSTS + LIKES + SAVES
-- ###########################

create table if not exists posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references profiles(id) on delete cascade,
  caption text,
  media_urls text[], -- array of public URLs
  media_type text default 'image', -- image, video, text
  location text,
  created_at timestamptz default now()
);

create index if not exists idx_posts_author on posts(author_id);
create index if not exists idx_posts_created_at on posts(created_at);

create table if not exists post_likes (
  id bigserial primary key,
  post_id uuid references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(post_id, user_id)
);

create index if not exists idx_post_likes_post on post_likes(post_id);
create index if not exists idx_post_likes_user on post_likes(user_id);

create table if not exists post_saves (
  id bigserial primary key,
  post_id uuid references posts(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(post_id, user_id)
);

create index if not exists idx_post_saves_user on post_saves(user_id);

-- ###########################
-- 5) COMMENTS + LIKES ON COMMENTS
-- ###########################

create table if not exists comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references posts(id) on delete cascade,
  author_id uuid references profiles(id) on delete cascade,
  parent_id uuid references comments(id) on delete cascade,
  content text not null,
  likes int default 0,
  created_at timestamptz default now()
);

create index if not exists idx_comments_post on comments(post_id);
create index if not exists idx_comments_author on comments(author_id);

create table if not exists comment_likes (
  id bigserial primary key,
  comment_id uuid references comments(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(comment_id, user_id)
);

create index if not exists idx_comment_likes_comment on comment_likes(comment_id);

-- ###########################
-- 6) STORIES
-- ###########################

create table if not exists stories (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references profiles(id) on delete cascade,
  media_url text not null,
  media_type text default 'image', -- image or video
  created_at timestamptz default now(),
  expires_at timestamptz not null
);

create index if not exists idx_stories_author on stories(author_id);
create index if not exists idx_stories_expires on stories(expires_at);

create table if not exists story_views (
  id bigserial primary key,
  story_id uuid references stories(id) on delete cascade,
  viewer_id uuid references profiles(id) on delete cascade,
  viewed_at timestamptz default now(),
  unique(story_id, viewer_id)
);

-- ###########################
-- 7) REELS
-- ###########################

create table if not exists reels (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references profiles(id) on delete cascade,
  video_url text not null,
  caption text,
  likes int default 0,
  created_at timestamptz default now()
);

create index if not exists idx_reels_author on reels(author_id);

create table if not exists reel_likes (
  id bigserial primary key,
  reel_id uuid references reels(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  created_at timestamptz default now(),
  unique(reel_id, user_id)
);

-- ###########################
-- 8) MESSAGING
-- ###########################

create table if not exists conversations (
  id uuid primary key default gen_random_uuid(),
  title text,
  created_at timestamptz default now()
);

create table if not exists conversation_members (
  id bigserial primary key,
  conversation_id uuid references conversations(id) on delete cascade,
  user_id uuid references profiles(id) on delete cascade,
  joined_at timestamptz default now(),
  unique(conversation_id, user_id)
);

create table if not exists messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid references conversations(id) on delete cascade,
  sender_id uuid references profiles(id) on delete cascade,
  content text,
  created_at timestamptz default now(),
  read boolean default false
);

create index if not exists idx_messages_conversation on messages(conversation_id);
create index if not exists idx_messages_sender on messages(sender_id);

-- ###########################
-- 9) TRIGGERS & RPC FUNCTIONS
-- ###########################

-- Function: increment comment.likes when comment_likes inserted
create or replace function fn_increment_comment_likes() returns trigger as $$
begin
  update comments set likes = likes + 1 where id = new.comment_id;
  return new;
end;
$$ language plpgsql;

create trigger trg_comment_like_inc
after insert on comment_likes
for each row execute procedure fn_increment_comment_likes();

-- Function: decrement comment.likes when comment_likes deleted
create or replace function fn_decrement_comment_likes() returns trigger as $$
begin
  update comments set likes = greatest(coalesce(likes,0) - 1, 0) where id = old.comment_id;
  return old;
end;
$$ language plpgsql;

create trigger trg_comment_like_dec
after delete on comment_likes
for each row execute procedure fn_decrement_comment_likes();

-- RPC: like_post(user toggles)
create or replace function like_post(p_post_id uuid, p_user uuid)
returns boolean as $$
declare
  v_exists int;
begin
  select count(*) into v_exists from post_likes where post_id = p_post_id and user_id = p_user;
  if v_exists = 0 then
    insert into post_likes(post_id, user_id) values (p_post_id, p_user);
    return true;
  else
    delete from post_likes where post_id = p_post_id and user_id = p_user;
    return false;
  end if;
end;
$$ language plpgsql;

-- RPC: like_reel
create or replace function like_reel(p_reel_id uuid, p_user uuid)
returns boolean as $$
declare v_exists int;
begin
  select count(*) into v_exists from reel_likes where reel_id = p_reel_id and user_id = p_user;
  if v_exists = 0 then
    insert into reel_likes(reel_id, user_id) values (p_reel_id, p_user);
    update reels set likes = likes + 1 where id = p_reel_id;
    return true;
  else
    delete from reel_likes where reel_id = p_reel_id and user_id = p_user;
    update reels set likes = greatest(coalesce(likes,0) - 1,0) where id = p_reel_id;
    return false;
  end if;
end;
$$ language plpgsql;

-- RPC: like_comment (insert into comment_likes)
create or replace function like_comment(p_comment_id uuid, p_user uuid)
returns boolean as $$
declare v_exists int;
begin
  select count(*) into v_exists from comment_likes where comment_id = p_comment_id and user_id = p_user;
  if v_exists = 0 then
    insert into comment_likes(comment_id, user_id) values (p_comment_id, p_user);
    return true;
  else
    delete from comment_likes where comment_id = p_comment_id and user_id = p_user;
    return false;
  end if;
end;
$$ language plpgsql;

-- RPC: create_or_get_conversation(user1, user2)
create or replace function create_or_get_conversation(user1 uuid, user2 uuid)
returns uuid as $$
declare
  v_conv uuid;
begin
  select c.id into v_conv
  from conversations c
  join conversation_members m1 on m1.conversation_id = c.id and m1.user_id = user1
  join conversation_members m2 on m2.conversation_id = c.id and m2.user_id = user2
  limit 1;

  if v_conv is not null then
    return v_conv;
  end if;

  insert into conversations (title) values (null) returning id into v_conv;
  insert into conversation_members(conversation_id, user_id) values (v_conv, user1);
  insert into conversation_members(conversation_id, user_id) values (v_conv, user2);
  return v_conv;
end;
$$ language plpgsql;

-- Trigger: create notification on post_like
create or replace function fn_notify_on_post_like() returns trigger as $$
begin
  insert into notifications(receiver_id, sender_id, type, data)
  select p.author_id, new.user_id, 'like', jsonb_build_object('post_id', new.post_id);
  return new;
end;
$$ language plpgsql;

create trigger trg_notify_post_like
after insert on post_likes
for each row execute procedure fn_notify_on_post_like();

-- Trigger: notify on comment
create or replace function fn_notify_on_comment() returns trigger as $$
declare v_post_author uuid;
begin
  select author_id into v_post_author from posts where id = new.post_id;
  if v_post_author is not null and v_post_author != new.author_id then
    insert into notifications(receiver_id, sender_id, type, data)
    values (v_post_author, new.author_id, 'comment', jsonb_build_object('post_id', new.post_id, 'comment_id', new.id));
  end if;
  return new;
end;
$$ language plpgsql;

create trigger trg_notify_on_comment
after insert on comments
for each row execute procedure fn_notify_on_comment();

-- Trigger: notify on follow (for public follow creation, follow_requests handled separately)
create or replace function fn_notify_on_follow() returns trigger as $$
begin
  insert into notifications(receiver_id, sender_id, type, data)
  select new.followed_id, new.follower_id, 'follow', jsonb_build_object();
  return new;
end;
$$ language plpgsql;

create trigger trg_notify_on_follow
after insert on follows
for each row execute procedure fn_notify_on_follow();

-- ###########################
-- 10) RLS Policies
-- ###########################

-- Enable RLS on sensitive tables
alter table profiles enable row level security;
alter table posts enable row level security;
alter table post_likes enable row level security;
alter table post_saves enable row level security;
alter table comments enable row level security;
alter table follows enable row level security;
alter table follow_requests enable row level security;
alter table notifications enable row level security;
alter table conversations enable row level security;
alter table conversation_members enable row level security;
alter table messages enable row level security;

-- Helper to get current_user id from auth
-- Supabase provides auth.uid(); we use this in policies

-- Profiles: allow users to select public profiles, and select own private profile
create policy "profiles_select_public" on profiles
  for select using (not is_private or auth.role() = 'service_role' or auth.uid() = id);

create policy "profiles_update_own" on profiles
  for update using (auth.uid() = id);

-- Posts: allow public select, allow insert for authenticated users, allow delete/update only owner
create policy "posts_public_select" on posts
  for select using (true);

create policy "posts_insert_auth" on posts
  for insert with check (auth.uid() = author_id);

create policy "posts_modify_owner" on posts
  for update, delete using (auth.uid() = author_id);

-- post_likes: allow insert/delete for authenticated users only; select public
create policy "post_likes_insert" on post_likes
  for insert with check (auth.uid() = user_id);

create policy "post_likes_delete" on post_likes
  for delete using (auth.uid() = user_id);

create policy "post_likes_select" on post_likes
  for select using (true);

-- post_saves policies
create policy "post_saves_insert" on post_saves
  for insert with check (auth.uid() = user_id);

create policy "post_saves_delete" on post_saves
  for delete using (auth.uid() = user_id);

create policy "post_saves_select" on post_saves
  for select using (auth.uid() = user_id);

-- comments policies
create policy "comments_select" on comments
  for select using (true);

create policy "comments_insert" on comments
  for insert with check (auth.uid() = author_id);

create policy "comments_delete" on comments
  for delete using (auth.uid() = author_id);

create policy "comments_update" on comments
  for update using (auth.uid() = author_id);

-- follows / follow_requests
create policy "follows_insert_auth" on follows
  for insert with check (auth.uid() = follower_id);

create policy "follows_delete_auth" on follows
  for delete using (auth.uid() = follower_id or auth.uid() = followed_id);

create policy "follow_requests_insert_auth" on follow_requests
  for insert with check (auth.uid() = requester_id);

create policy "follow_requests_delete_auth" on follow_requests
  for delete using (auth.uid() = requester_id or auth.uid() = target_id);

create policy "follows_select" on follows
  for select using (true);

-- notifications: select only receiver
create policy "notifications_select_receiver" on notifications
  for select using (auth.uid() = receiver_id);

create policy "notifications_insert_auth" on notifications
  for insert with check (true); -- allow backend inserts (triggers) and service_role

create policy "notifications_update_receiver" on notifications
  for update using (auth.uid() = receiver_id);

-- conversations and messages policies
create policy "conversations_select" on conversations
  for select using (exists (select 1 from conversation_members m where m.conversation_id = conversations.id and m.user_id = auth.uid()));

create policy "conversation_members_insert" on conversation_members
  for insert with check (auth.uid() = user_id);

create policy "messages_select" on messages
  for select using (exists (select 1 from conversation_members m where m.conversation_id = messages.conversation_id and m.user_id = auth.uid()));

create policy "messages_insert" on messages
  for insert with check (auth.uid() = sender_id);

create policy "messages_update" on messages
  for update using (auth.uid() = sender_id);

-- ###########################
-- 11) INDEXES for performance
-- ###########################

create index if not exists idx_posts_caption_trgm on posts using gin ((coalesce(caption, '')) gin_trgm_ops);
create index if not exists idx_comments_content_trgm on comments using gin ((coalesce(content, '')) gin_trgm_ops);

-- ###########################
-- 12) SEED (optional) - admin user
-- ###########################

-- Uncomment and set your admin email if you want a seeded admin
-- insert into profiles (id, email, username, full_name, role)
-- values ('00000000-0000-0000-0000-000000000000','admin@example.com','admin','Admin User','admin')
-- on conflict (id) do nothing;

-- ###########################
-- 13) Notes
-- ###########################
-- After running this file:
-- 1) Create storage buckets: avatars, posts, reels, stories (public or private as preferred)
-- 2) If using private buckets, create signed_url flows in backend.
-- 3) Review RLS policies to ensure they match your security model.
-- 4) Consider migrating this monolithic schema into individual migrations for maintainability.

create table stories (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  media_url text not null,
  media_type text not null, -- image/video
  caption text,
  created_at timestamptz default now()
);
