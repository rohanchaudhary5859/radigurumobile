import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../profile/profile_screen.dart';
import 'search_controller.dart' as search;
import 'widgets/search_result_tile.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(search.searchControllerProvider);
    final controller = ref.read(search.searchControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search doctors, topics, videos...',
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onChanged: controller.setQuery,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab bar for search categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _buildTab(context, 'Doctors', 'doctors', state.activeTab, controller),
                _buildTab(context, 'Topics', 'topics', state.activeTab, controller),
                _buildTab(context, 'Videos', 'videos', state.activeTab, controller),
                _buildTab(context, 'Cases', 'cases', state.activeTab, controller),
              ],
            ),
          ),
          // Search results
          Expanded(
            child: state.loading
                ? const Center(child: CircularProgressIndicator())
                : state.results.isEmpty
                    ? const Center(
                        child: Text('Search for doctors, topics, videos, or cases'),
                      )
                    : ListView.builder(
                        itemCount: state.results.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.results.length && state.hasMore) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          
                          final result = state.results[index];
                          return SearchResultTile(
                            result: result,
                            onTap: () {
                              if (state.activeTab == 'doctors') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(userId: result['id']),
                                  ),
                                );
                              }
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, String tab, String activeTab, search.AppSearchController controller) {
    final isActive = activeTab == tab;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (_) => controller.setTab(tab),
        backgroundColor: isActive ? Theme.of(context).primaryColor.withAlpha(26) : null,
        selectedColor: Theme.of(context).primaryColor.withAlpha(51),
      ),
    );
  }
}