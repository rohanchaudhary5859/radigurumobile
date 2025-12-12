import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'story_service.dart';

final storyControllerProvider =
    StateNotifierProvider<StoryController, StoryState>(
  (ref) => StoryController(),
);

class StoryState {
  final bool loading;

  StoryState({this.loading = false});

  StoryState copyWith({bool? loading}) {
    return StoryState(loading: loading ?? this.loading);
  }
}

class StoryController extends StateNotifier<StoryState> {
  StoryController() : super(StoryState());

  final _service = StoryService();

  Future<void> createStory({
    required File file,
    required String mediaType,
    required String caption,
  }) async {
    state = state.copyWith(loading: true);

    await _service.uploadStory(
      file: file,
      mediaType: mediaType,
      caption: caption,
    );

    state = state.copyWith(loading: false);
  }
}
