import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_client/common/constants.dart';
import 'package:asr_client/providers/settings_providers.dart';
import 'package:asr_client/theme/app_colors.dart';

class ServerSettingsDialog extends ConsumerStatefulWidget {
  const ServerSettingsDialog({super.key});

  @override
  ConsumerState<ServerSettingsDialog> createState() =>
      _ServerSettingsDialogState();
}

class _ServerSettingsDialogState extends ConsumerState<ServerSettingsDialog> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;

  @override
  void initState() {
    super.initState();
    final host =
        ref.read(serverHostProvider).valueOrNull ?? AppConstants.defaultHost;
    final port =
        ref.read(serverPortProvider).valueOrNull ?? AppConstants.defaultPort;
    _hostController = TextEditingController(text: host);
    _portController = TextEditingController(text: port.toString());
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('服务器设置'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _hostController,
            decoration: const InputDecoration(
              labelText: '主机地址',
              hintText: '例如 localhost',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _portController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '端口',
              hintText: '例如 8765',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _save, child: const Text('保存')),
      ],
    );
  }

  Future<void> _save() async {
    final host = _hostController.text.trim();
    final port =
        int.tryParse(_portController.text.trim()) ?? AppConstants.defaultPort;

    if (host.isEmpty) return;

    final service = ref.read(settingsServiceProvider);
    await service.setHost(host);
    await service.setPort(port);

    if (mounted) Navigator.of(context).pop();
  }
}
