import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/search_service.dart';

final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>(
  (ref) => SearchController(),
);

class SearchState {
  final bool loading;
  final List<Map<String, dynamic>> results;
  final List<String> suggestions;
  final String query;
  final String activeTab; // 'doctors' | 'topics' | 'videos' | 'cases'
  final bool hasMore;

  SearchState({
    this.loading = false,
    this.results = const [],
    this.suggestions = const [],
    this.query = '',
    this.activeTab = 'doctors',
    this.hasMore = true,
  });

  SearchState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? results,
    List<String>? suggestions,
    String? query,
    String? activeTab,
    bool? hasMore,
  }) {
    return SearchState(
      loading: loading ?? this.loading,
      results: results ?? this.results,
      suggestions: suggestions ?? this.suggestions,
      query: query ?? this.query,
      activeTab: activeTab ?? this.activeTab,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class SearchController extends StateNotifier<SearchState> {
  final SearchService _service = SearchService();
  Timer? _debounce;
  int _page = 0;
  final int _limit = 20;

  SearchController() : super(SearchState());

  void setTab(String tab) {
    state = state.copyWith(activeTab: tab, results: [], hasMore: true);
    if (state.query.isNotEmpty) search(state.query, reset: true);
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _suggest(q));
  }

  Future<void> _suggest(String q) async {
    if (q.isEmpty) {
      state = state.copyWith(suggestions: []);
      return;
    }
    try {
      final s = await _service.suggest(q, limit: 10);
      state = state.copyWith(suggestions: s);
    } catch (_) {
      state = state.copyWith(suggestions: []);
    }
  }

  Future<void> search(String q, {bool reset = false}) async {
    if (q.isEmpty) {
      state = state.copyWith(results: [], suggestions: []);
      return;
    }

    try {
      state = state.copyWith(loading: true, query: q);
      if (reset) {
        _page = 0;
      }

      final offset = _page * _limit;
      List<Map<String, dynamic>> fetched = [];

      switch (state.activeTab) {
        case 'doctors':
          fetched = await _service.searchDoctors(q, limit: _limit, offset: offset);
          break;
        case 'videos':
          fetched = await _service.searchPosts(q, mediaType: 'video', limit: _limit, offset: offset);
          break;
        case 'topics':
        case 'cases':
        default:
          fetched = await _service.searchPosts(q, mediaType: 'image', limit: _limit, offset: offset);
      }

      final newResults = reset ? fetched : [...state.results, ...fetched];
      final hasMore = fetched.length == _limit;

      state = state.copyWith(results: newResults, loading: false, hasMore: hasMore);
      if (hasMore) _page++;
    } catch (e) {
      state = state.copyWith(loading: false);
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.loading) return;
    await search(state.query, reset: false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
