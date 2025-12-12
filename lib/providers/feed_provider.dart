import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/home/controller/feed_controller.dart';

final feedProvider = Provider<FeedState>((ref) {
  return ref.watch(feedControllerProvider);
});
