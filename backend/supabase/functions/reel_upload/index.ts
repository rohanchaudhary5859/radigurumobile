// supabase/functions/reel_upload/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

export async function handler(req: Request) {
  try {
    if (req.method !== 'POST') return new Response(JSON.stringify({ error: 'Method not allowed' }), { status: 405 });

    const SUPABASE_URL = Deno.env.get('https://pqsfrhjngaklrijtjnfh.supabase.co')!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBxc2ZyaGpuZ2FrbHJpanRqbmZoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTM3MTAxNCwiZXhwIjoyMDgwOTQ3MDE0fQ.w3Q5k2t1lCHuIS_GXUNO0ozkZdfyjLvqfLdSePrqqLc')!;
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const body = await req.json();
    const { author_id, video_url, caption } = body;

    if (!author_id || !video_url) return new Response(JSON.stringify({ error: 'author_id and video_url required' }), { status: 400 });

    const res = await supabase.from('reels').insert([{ author_id, video_url, caption: caption ?? null }]).select().single();
    if (res.error) return new Response(JSON.stringify({ error: res.error.message }), { status: 500 });

    // Optionally generate thumbnail job asynchronously (not implemented here)

    return new Response(JSON.stringify({ success: true, reel: res.data }), { status: 201, headers: { 'Content-Type': 'application/json' } });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 });
  }
}
