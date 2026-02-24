import 'package:flutter/material.dart';
import '../services/permissions_service.dart';

class OptionsSheet extends StatelessWidget {
  const OptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Request Microphone Permission'),
            subtitle: const Text('Needed for recording + level detection'),
            trailing: const Icon(Icons.mic),
            onTap: () async {
              final ok = await PermissionsService.ensureAudioPermissions();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ok ? 'Permission Granted' : 'Permission Denied')),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          const ListTile(
            title: Text('More settings'),
            subtitle: Text('You can add controls here (language, sounds, etc.)'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
