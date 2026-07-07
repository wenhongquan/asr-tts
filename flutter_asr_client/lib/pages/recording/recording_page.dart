import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:asr_client/pages/recording/notifiers/recording_notifier.dart';
import 'package:asr_client/pages/recording/widgets/bottom_controls.dart';
import 'package:asr_client/pages/recording/widgets/conversation_list.dart';
import 'package:asr_client/pages/recording/widgets/recording_header.dart';
import 'package:asr_client/theme/app_colors.dart';

class RecordingPage extends ConsumerWidget {
  const RecordingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(recordingNotifierProvider);

    ref.listen(recordingNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => _showErrorSnackBar(context, error.toString()),
        data: (state) {
          if (state.errorMessage != null) {
            _showErrorSnackBar(context, state.errorMessage!);
            ref.read(recordingNotifierProvider.notifier).clearError();
          }
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.nav,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => _onBack(context, ref, asyncState.valueOrNull),
        ),
        title: const Text(
          '实时语音识别',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          _ConnectionIndicator(
            isConnected: asyncState.valueOrNull?.isConnected ?? false,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: asyncState.when(
          loading: () => const _LoadingView(),
          error: (error, _) => _ErrorView(message: error.toString()),
          data: (state) => _RecordingBody(state: state),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onBack(BuildContext context, WidgetRef ref, RecordingState? state) {
    if (state != null && state.status != RecordingStatus.idle) {
      _showEndConfirmDialog(context, ref);
      return;
    }
    if (context.mounted) context.go('/tasks');
  }

  Future<void> _showEndConfirmDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final notifier = ref.read(recordingNotifierProvider.notifier);
    notifier.endRecording();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('结束录音？'),
        content: const Text('结束录音后将生成报告并返回首页。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('结束并生成报告'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await notifier.confirmEnd();
      if (context.mounted) context.go('/reports');
    } else {
      notifier.cancelEnd();
    }
  }
}

class _ConnectionIndicator extends StatelessWidget {
  const _ConnectionIndicator({required this.isConnected});

  final bool isConnected;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isConnected ? AppColors.ok : AppColors.warn,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isConnected ? '已连接' : '连接中',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.app),
          SizedBox(height: 14),
          Text('正在连接服务器并启动录音...', style: TextStyle(color: AppColors.ink2)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.ink2),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/tasks'),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingBody extends ConsumerWidget {
  const _RecordingBody({required this.state});

  final RecordingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(recordingNotifierProvider.notifier);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RecordingHeader(
                  projectName: state.projectName ?? '',
                  taskName: state.taskName ?? '',
                  templateName: state.templateName ?? '',
                ),
                const SizedBox(height: 8),
                ConversationList(
                  items: state.items,
                  liveUtterance: state.liveUtterance,
                  isRecording: state.isRecording,
                ),
              ],
            ),
          ),
        ),
        BottomControls(
          status: state.status,
          elapsed: state.elapsed,
          audioLevel: state.audioLevel,
          onPause: notifier.pauseRecording,
          onResume: notifier.resumeRecording,
          onEnd: () => _RecordingPageHelper.showEndConfirm(context, ref),
        ),
      ],
    );
  }
}

class _RecordingPageHelper {
  static void showEndConfirm(BuildContext context, WidgetRef ref) {
    const RecordingPage()._showEndConfirmDialog(context, ref);
  }
}
