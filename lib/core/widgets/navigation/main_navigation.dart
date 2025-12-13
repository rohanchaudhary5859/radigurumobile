import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/home/home_screen.dart';
import '../../../features/search/search_screen.dart';
import '../../../features/reels/reels_screen.dart';
import '../../../features/messages/messages_list_screen.dart';
import '../../../features/profile/profile_screen.dart';

// Explicitly import the classes to ensure they're recognized
class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const HomeScreen();
}
class SearchScreenWrapper extends StatelessWidget {
  const SearchScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const SearchScreen();
}
class ReelsScreenWrapper extends StatelessWidget {
  const ReelsScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const ReelsScreen();
}
class MessagesListScreenWrapper extends StatelessWidget {
  const MessagesListScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const MessagesListScreen();
}
class ProfileScreenWrapper extends StatelessWidget {
  const ProfileScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const ProfileScreen();
}

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenWrapper(),
    const SearchScreenWrapper(),
    const ReelsScreenWrapper(),
    const MessagesListScreenWrapper(),
    const ProfileScreenWrapper(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.search_outlined,
                  activeIcon: Icons.search,
                  label: 'Search',
                  index: 1,
                ),
                _buildNavItem(
                  icon: Icons.play_circle_outline,
                  activeIcon: Icons.play_circle,
                  label: 'Reels',
                  index: 2,
                ),
                _buildNavItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: 'Chat',
                  index: 3,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  index: 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Theme.of(context).primaryColor : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
