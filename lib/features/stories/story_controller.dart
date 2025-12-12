import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/story_service.dart';

final storyControllerProvider =
    StateNotifierProvider<StoryController, StoryState>(
  (ref) => StoryController(ref),
);

class StoryState {
  final bool loading;
  final List<Map<String, dynamic>> stories;

  StoryState({this.loading = false, this.stories = const []});

  StoryState copyWith({bool? loading, List<Map<String, dynamic>>? stories}) {
    return StoryState(
      loading: loading ?? this.loading,
      stories: stories ?? this.stories,
    );
  }
}

class StoryController extends StateNotifier<StoryState> {
  final Ref ref;
  StoryController(this.ref) : super(StoryState()) {
    loadStories();
  }

  final _service = StoryService();
  final _client = Supabase.instance.client;

  String? get userId => _client.auth.currentUser?.id;

  Future<void> loadStories() async {
    state = state.copyWith(loading: true);

    final data = await _service.fetchStories();
    state = state.copyWith(stories: data, loading: false);
  }

  Future<void> uploadStory(File file) async {
    if (userId == null) return;

    state = state.copyWith(loading: true);

    final url = await _service.uploadStoryMedia(file, userId!);
    final mediaType = file.path.toLowerCase().endsWith(".mp4") ? "video" : "image";

    await _service.createStory(userId!, url, mediaType);

    await loadStories();
  }
}
