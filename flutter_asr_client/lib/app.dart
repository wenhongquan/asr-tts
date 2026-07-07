import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/theme/app_theme.dart';
import 'package:asr_client/router/app_router.dart';

class AsrApp extends ConsumerWidget {
  const AsrApp({super.key, this.overrides = const []});

  final List<Override> overrides;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp.router(
        title: '检测数据采集',
        theme: AppTheme.light,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
