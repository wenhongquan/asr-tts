import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:asr_client/theme/app_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  int get _currentIndex => navigationShell.currentIndex;

  void _onTap(BuildContext context, int index) {
    if (index == 2) {
      // FAB — navigate to recording page
      GoRouter.of(context).go('/recording');
      return;
    }
    // Adjust index: tab 0=tasks, 1=records, 2=FAB(skip), 3=reports→2, 4=profile→3
    final adjustedIndex = index > 2 ? index - 1 : index;
    navigationShell.goBranch(
      adjustedIndex,
      initialLocation: adjustedIndex == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onTap(context, index),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: const EdgeInsets.only(bottom: 6),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            _TabItem(
              icon: Icons.task_alt,
              label: '任务',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _TabItem(
              icon: Icons.folder_open,
              label: '记录',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            _FabButton(onTap: () => onTap(2)),
            _TabItem(
              icon: Icons.bar_chart,
              label: '报告',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _TabItem(
              icon: Icons.person,
              label: '我的',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.app : AppColors.ink3,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.app : AppColors.ink3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FabButton extends StatelessWidget {
  const _FabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, -16),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.app, AppColors.appDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: AppColors.card, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.app.withValues(alpha: 0.6),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
