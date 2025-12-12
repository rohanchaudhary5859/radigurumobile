// supabase/functions/get_user_profile/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export async function handler(req: Request) {
  try {
    const SUPABASE_URL = Deno.env.get('https://pqsfrhjngaklrijtjnfh.supabase.co')!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxc2ZyaGpuZ2FrbHJpanRqbmZoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTM3MTAxNCwiZXhwIjoyMDgwOTQ3MDE0fQ.w3Q5k2t1lCHuIS_GXUNO0ozkZdfyjLvqfLdSePrqqLc')!;
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const url = new URL(req.url);
    const userId = url.searchParams.get('user_id');
    const postsLimit = parseInt(url.searchParams.get('posts_limit') || '12');

    if (!userId) return new Response(JSON.stringify({ error: 'user_id required' }), { status: 400 });

    // profile
    const profileRes = await supabase.from('profiles').select('id, username, full_name, bio, specialization, avatar_url, is_private').eq('id', userId).maybeSingle();
    if (profileRes.error) return new Response(JSON.stringify({ error: profileRes.error.message }), { status: 500 });
    if (!profileRes.data) return new Response(JSON.stringify({ error: 'not_found' }), { status: 404 });

    // counts
    const postsCountRes = await supabase.from('posts').select('id', { count: 'exact' }).eq('author_id', userId);
    const followersCountRes = await supabase.from('follows').select('id', { count: 'exact' }).eq('followed_id', userId);
    const followingCountRes = await supabase.from('follows').select('id', { count: 'exact' }).eq('follower_id', userId);

    if (postsCountRes.error || followersCountRes.error || followingCountRes.error) {
      return new Response(JSON.stringify({ error: 'count_error' }), { status: 500 });
    }

    const recentPostsRes = await supabase
      .from('posts')
      .select('id, media_urls, caption, media_type, created_at')
      .eq('author_id', userId)
      .order('created_at', { ascending: false })
      .limit(postsLimit);

    if (recentPostsRes.error) return new Response(JSON.stringify({ error: recentPostsRes.error.message }), { status: 500 });

    const payload = {
      profile: profileRes.data,
      counts: {
        posts: postsCountRes.count ?? 0,
        followers: followersCountRes.count ?? 0,
        following: followingCountRes.count ?? 0
      },
      recent_posts: recentPostsRes.data
    };

    return new Response(JSON.stringify(payload), { status: 200, headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
}
