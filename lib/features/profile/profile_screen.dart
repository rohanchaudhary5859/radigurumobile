import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/avatar.dart';
import '../../providers/profile_provider.dart';
import 'edit_profile_screen.dart';
import '../../core/services/profile_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId; // optional -> view other profiles
  const ProfileScreen({super.key, this.userId});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileService _profileService = ProfileService();
  List<Map<String, dynamic>> posts = [];
  bool loadingPosts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    await ref.read(profileControllerProvider.notifier).loadProfile(id: widget.userId);
    await _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => loadingPosts = true);
    final uid = widget.userId ?? ref.read(profileControllerProvider.notifier).userId;
    if (uid != null) {
      posts = await _profileService.getUserPosts(uid);
    }
    setState(() => loadingPosts = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileControllerProvider);
    final profile = state.profile ?? {};
    return Scaffold(
      appBar: AppBar(
        title: Text(profile['username'] ?? 'Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
              if (res == true) {
                ref.read(profileControllerProvider.notifier).loadProfile();
                _loadPosts();
              }
            },
          )
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(profileControllerProvider.notifier).loadProfile();
                await _loadPosts();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Avatar(url: profile['avatar_url'], size: 88, onTap: () {}),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(profile['full_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(profile['specialization'] ?? '', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 6),
                            Text(profile['hospital_name'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(profile['bio'] ?? '', style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statItem('Posts', posts.length),
                      _statItem('Followers', profile['followers_count'] ?? 0),
                      _statItem('Following', profile['following_count'] ?? 0),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TabBar(controller: _tabController, tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Reels'),
                    Tab(text: 'Saved'),
                  ]),
                  SizedBox(
                    height: 600,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        loadingPosts
                            ? const Center(child: CircularProgressIndicator())
                            : _postsGrid(posts),
                        const Center(child: Text('Reels - to implement')),
                        FutureBuilder(
                          future: ref.read(profileControllerProvider.notifier).userId == null
                              ? Future.value([])
                              : ref.read(profileControllerProvider.notifier)._service.getSavedPosts(ref.read(profileControllerProvider.notifier).userId!),
                          builder: (context, snap) {
                            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                            final saved = snap.data as List<Map<String, dynamic>>;
                            return _postsGrid(saved);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _postsGrid(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return const Center(child: Text('No posts'));
    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: list.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 2, crossAxisSpacing: 2),
      itemBuilder: (context, i) {
        final item = list[i];
        final media = (item['media_urls'] as List<dynamic>?) ?? [];
        final thumb = media.isNotEmpty ? media[0] as String : null;
        return thumb == null
            ? Container(color: Colors.grey[200])
            : Image.network(thumb, fit: BoxFit.cover);
      },
    );
  }

  Widget _statItem(String label, int num) {
    return Column(
      children: [
        Text(num.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
