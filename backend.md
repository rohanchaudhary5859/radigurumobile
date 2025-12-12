backend/
 └── supabase/
     ├── migrations/
     │     ├── 000_init.sql
     │     ├── 001_profiles.sql
     │     ├── 002_posts.sql
     │     ├── 003_stories.sql
     │     ├── 004_messages.sql
     │     ├── 005_notifications.sql
     │     └── 006_settings.sql
     │
     ├── functions/
     │     ├── sendNotification/
     │     │        └── index.ts
     │     ├── verifyDoctor/
     │     │        └── index.ts
     │     └── optimizeImage/
     │             └── index.ts
     │
     ├── storage/
     │     ├── avatars/
     │     ├── posts/
     │     └── stories/
     │
     ├── supabase.toml
     └── types/                    # Auto generated types
