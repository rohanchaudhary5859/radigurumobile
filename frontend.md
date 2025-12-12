app/
└── lib/
    ├── main.dart
    ├── app_router.dart
    ├── core/
    │     ├── theme/
    │     │     ├── colors.dart
    │     │     └── app_theme.dart
    │     ├── utils/
    │     ├── constants/
    │     │      └── app_strings.dart
    │     ├── services/
    │     │      ├── supabase_service.dart
    │     │      ├── storage_service.dart
    │     │      ├── messaging_service.dart
    │     │      └── notification_service.dart
    │     └── widgets/
    │            ├── app_button.dart
    │            ├── app_input.dart
    │            ├── avatar.dart
    │            ├── shimmer.dart
    │            └── bottom_nav.dart
    │
    ├── features/
    │     ├── auth/
    │     │    ├── login_screen.dart
    │     │    ├── signup_screen.dart
    │     │    ├── otp_screen.dart
    │     │    └── controller/
    │     │          └── auth_controller.dart
    │     │
    │     ├── splash/
    │     │    └── splash_screen.dart
    │     │
    │     ├── home/
    │     │    ├── home_screen.dart
    │     │    ├── widgets/
    │     │    │      ├── feed_post.dart
    │     │    │      └── story_bar.dart
    │     │    └── controller/
    │     │           └── feed_controller.dart
    │     │
    │     ├── search/
    │     │    ├── search_screen.dart
    │     │    ├── doctors_tab.dart
    │     │    ├── topics_tab.dart
    │     │    ├── videos_tab.dart
    │     │    └── cases_tab.dart
    │     │
    │     ├── messages/
    │     │    ├── messages_list_screen.dart
    │     │    ├── chat_screen.dart
    │     │    └── controller/
    │     │           └── message_controller.dart
    │     │
    │     ├── create/
    │     │    ├── create_post_screen.dart
    │     │    ├── create_story_screen.dart
    │     │    └── reel_upload_screen.dart
    │     │
    │     ├── profile/
    │     │    ├── profile_screen.dart
    │     │    ├── edit_profile_screen.dart
    │     │    └── controller/
    │     │           └── profile_controller.dart
    │     │
    │     ├── settings/
    │     │    ├── settings_screen.dart
    │     │    ├── change_password_screen.dart
    │     │    └── controller/
    │     │           └── settings_controller.dart
    │     │
    │     └── notifications/
    │            ├── notifications_screen.dart
    │            └── controller/
    │                   └── notifications_controller.dart
    │
    └── providers/
          ├── auth_provider.dart
          ├── profile_provider.dart
          ├── feed_provider.dart
          ├── message_provider.dart
          └── settings_provider.dart
