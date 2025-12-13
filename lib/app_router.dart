import 'package:flutter/material.dart';
import 'app_router_args.dart';

// AUTH SCREENS
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/otp/otp_screen.dart';

// HOME + MAIN SCREENS
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/reels/reels_screen.dart';
import 'features/create/create_post_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'core/widgets/navigation/bottom_nav.dart';

// PROFILE
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';

// USER PROFILE (OTHER USERS)
import 'features/user_profile/user_profile_screen.dart';
import 'features/user_profile/user_posts_screen.dart';

// POSTS
import 'features/post_detail/post_detail_screen.dart';
import 'features/comments/comments_screen.dart';

// STORIES
import 'features/stories/story_upload_screen.dart';
import 'features/stories/story_viewer.dart';

// FOLLOW
import 'features/follow/followers_screen.dart';
import 'features/follow/following_screen.dart';

// MESSAGES
import 'features/messages/messages_list_screen.dart';
import 'features/messages/chat_screen.dart';

// SETTINGS
import 'features/settings/settings_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {

      // SPLASH
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      // AUTH
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());
      case '/otp':
        final args = settings.arguments as OtpArgs?;
        return MaterialPageRoute(
            builder: (_) => OtpScreen(args: args));

      // MAIN / HOME / NAVIGATION
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      // SEARCH
      case '/search':
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      // REELS
      case '/reels':
        return MaterialPageRoute(builder: (_) => const ReelsScreen());

      // CREATE POST
      case '/create-post':
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());

      // NOTIFICATIONS
      case '/notifications':
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());

      // PROFILE (CURRENT USER)
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case '/edit-profile':
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      // USER PROFILE (OTHER USERS)
      case '/user-profile':
        final args = settings.arguments as UserProfileArgs?;
        return MaterialPageRoute(
            builder: (_) => UserProfileScreen(args: args));
      case '/user-posts':
        final args = settings.arguments as UserPostsArgs?;
        return MaterialPageRoute(
            builder: (_) => UserPostsScreen(args: args));

      // POST DETAIL
      case '/post-detail':
        final args = settings.arguments as PostDetailArgs?;
        return MaterialPageRoute(
            builder: (_) => PostDetailScreen(args: args));

      // COMMENTS
      case '/comments':
        final args = settings.arguments as CommentsArgs?;
        return MaterialPageRoute(
            builder: (_) => CommentsScreen(args: args));

      // STORY
      case '/story-upload':
        return MaterialPageRoute(builder: (_) => const StoryUploadScreen());
      case '/story-viewer':
        final args = settings.arguments as StoryViewerArgs?;
        return MaterialPageRoute(
            builder: (_) => StoryViewer(args: args));

      // FOLLOW
      case '/followers':
        final args = settings.arguments as FollowersArgs?;
        return MaterialPageRoute(
            builder: (_) => FollowersScreen(args: args));
      case '/following':
        final args = settings.arguments as FollowingArgs?;
        return MaterialPageRoute(
            builder: (_) => FollowingScreen(args: args));

      // MESSAGES (INBOX + CHAT)
      case '/messages':
        return MaterialPageRoute(builder: (_) => const MessagesListScreen());
      // CHAT
      case '/chat':
        final args = settings.arguments as ChatArgs?;
        return MaterialPageRoute(
            builder: (_) => ChatScreen(args: args));

      // SETTINGS
      case '/settings':
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(child: Text("No route defined for ${settings.name}")),
                ));
    }
  }
}
