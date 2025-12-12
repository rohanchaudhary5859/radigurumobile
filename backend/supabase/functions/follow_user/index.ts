// supabase/functions/follow_user/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export async function handler(req: Request) {
  try {
    if (req.method !== 'POST') return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });

    const SUPABASE_URL = Deno.env.get('https://pqsfrhjngaklrijtjnfh.supabase.co')!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxc2ZyaGpuZ2FrbHJpanRqbmZoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTM3MTAxNCwiZXhwIjoyMDgwOTQ3MDE0fQ.w3Q5k2t1lCHuIS_GXUNO0ozkZdfyjLvqfLdSePrqqLc')!;
    
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { follower_id, target_id } = await req.json();
    if (!follower_id || !target_id) return new Response(JSON.stringify({ error: 'follower_id and target_id required' }), { status: 400 });

    // If already following -> unfollow
    const existing = await supabase
      .from('follows')
      .select('*')
      .eq('follower_id', follower_id)
      .eq('followed_id', target_id)
      .maybeSingle();

    if (existing.error) return new Response(JSON.stringify({ error: existing.error.message }), { status: 500 });

    if (existing.data) {
      const del = await supabase.from('follows').delete().eq('follower_id', follower_id).eq('followed_id', target_id);
      if (del.error) return new Response(JSON.stringify({ error: del.error.message }), { status: 500 });
      return new Response(JSON.stringify({ followed: false }), { status: 200 });
    }

    // Check if target is private
    const profile = await supabase.from('profiles').select('is_private').eq('id', target_id).maybeSingle();
    if (profile.error) return new Response(JSON.stringify({ error: profile.error.message }), { status: 500 });

    const isPrivate = profile.data?.is_private === true;

    if (isPrivate) {
      // create follow request if not exists
      const reqExists = await supabase
        .from('follow_requests')
        .select('*')
        .eq('requester_id', follower_id)
        .eq('target_id', target_id)
        .maybeSingle();

      if (reqExists.error) return new Response(JSON.stringify({ error: reqExists.error.message }), { status: 500 });
      if (reqExists.data) return new Response(JSON.stringify({ requested: true }), { status: 200 });

      const ins = await supabase.from('follow_requests').insert([{ requester_id: follower_id, target_id }]);
      if (ins.error) return new Response(JSON.stringify({ error: ins.error.message }), { status: 500 });
      return new Response(JSON.stringify({ requested: true }), { status: 201 });
    } else {
      // create follow
      const ins = await supabase.from('follows').insert([{ follower_id, followed_id: target_id }]).select().single();
      if (ins.error) return new Response(JSON.stringify({ error: ins.error.message }), { status: 500 });

      // create notification
      await supabase.from('notifications').insert([{
        receiver_id: target_id,
        sender_id: follower_id,
        type: 'follow',
        data: { info: 'followed' }
      }]);

      return new Response(JSON.stringify({ followed: true, follow: ins.data }), { status: 201 });
    }
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
}
