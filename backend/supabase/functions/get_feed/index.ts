// supabase/functions/get_feed/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export async function handler(req: Request) {
  try {
    const SUPABASE_URL = Deno.env.get('https://pqsfrhjngaklrijtjnfh.supabase.co')!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxc2ZyaGpuZ2FrbHJpanRqbmZoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTM3MTAxNCwiZXhwIjoyMDgwOTQ3MDE0fQ.w3Q5k2t1lCHuIS_GXUNO0ozkZdfyjLvqfLdSePrqqLc')!;
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const url = new URL(req.url);
    const userId = url.searchParams.get('user_id');
    const limit = parseInt(url.searchParams.get('limit') || '20');
    const offset = parseInt(url.searchParams.get('offset') || '0');

    if (!userId) return new Response(JSON.stringify({ error: 'user_id required' }), { status: 400 });

    // 1) Get IDs of users this user follows
    const followsRes = await supabase.from('follows').select('followed_id').eq('follower_id', userId);
    if (followsRes.error) return new Response(JSON.stringify({ error: followsRes.error.message }), { status: 500 });
    const followedIds = (followsRes.data as any[]).map(r => r.followed_id);

    // include own id
    const sourceIds = [userId, ...followedIds];

    // 2) Get posts from those authors
    const postsRes = await supabase
      .from('posts')
      .select('id, author_id, caption, media_urls, media_type, location, created_at, profiles(id, username, avatar_url)')
      .in('author_id', sourceIds)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1);

    if (postsRes.error) return new Response(JSON.stringify({ error: postsRes.error.message }), { status: 500 });

    return new Response(JSON.stringify({ posts: postsRes.data }), { status: 200, headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
}
