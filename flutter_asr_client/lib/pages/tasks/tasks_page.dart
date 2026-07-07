import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:asr_client/pages/tasks/widgets/section_header.dart';
import 'package:asr_client/pages/tasks/widgets/task_card.dart';
import 'package:asr_client/providers/task_providers.dart';
import 'package:asr_client/theme/app_colors.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(taskSectionsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        foregroundColor: AppColors.ink,
        elevation: 0,
        title: const Text(
          '今日任务',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.ink2),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        itemCount: sections.length * 2,
        itemBuilder: (context, index) {
          final sectionIndex = index ~/ 2;
          final section = sections[sectionIndex];
          if (index.isEven) {
            return SectionHeader(title: section.title, action: section.action);
          }
          return Column(
            children: section.tasks.asMap().entries.map((entry) {
              final cardIndex = index + entry.key;
              return _SlideFadeIn(
                key: ValueKey(entry.value.id),
                index: cardIndex,
                child: TaskCard(task: entry.value),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/recording'),
        backgroundColor: AppColors.app,
        icon: const Icon(Icons.mic, color: Colors.white),
        label: const Text(
          '新建检测',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SlideFadeIn extends StatefulWidget {
  const _SlideFadeIn({super.key, required this.child, required this.index});

  final Widget child;
  final int index;

  @override
  State<_SlideFadeIn> createState() => _SlideFadeInState();
}

class _SlideFadeInState extends State<_SlideFadeIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    final delay = Duration(milliseconds: (widget.index * 40).clamp(0, 400));
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
