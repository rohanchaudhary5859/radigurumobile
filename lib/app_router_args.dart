class ProfileArgs {
  final String userId;
  ProfileArgs({required this.userId});
}

class StoryArgs {
  final dynamic story; // replace with StoryModel later

  StoryArgs({required this.story});
}

class ChatArgs {
  final String conversationId;
  final dynamic otherUser; // replace with Profile later

  ChatArgs({
    required this.conversationId,
    required this.otherUser,
  });
}

class OtpArgs {
  final String phone;

  OtpArgs({required this.phone});
}

class UserProfileArgs {
  final String userId;

  UserProfileArgs({required this.userId});
}

class UserPostsArgs {
  final String userId;

  UserPostsArgs({required this.userId});
}

class PostDetailArgs {
  final String postId;

  PostDetailArgs({required this.postId});
}

class CommentsArgs {
  final String postId;

  CommentsArgs({required this.postId});
}

class StoryViewerArgs {
  final List stories;

  StoryViewerArgs({required this.stories});
}

class FollowersArgs {
  final String userId;

  FollowersArgs({required this.userId});
}

class FollowingArgs {
  final String userId;

  FollowingArgs({required this.userId});
}
