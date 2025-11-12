import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const ListTile(
            title: Text('Account'),
            subtitle: Text('Not connected'),
            leading: Icon(Icons.person),
          ),
          const Divider(),
          ListTile(
            title: const Text('Privacy Policy'),
            leading: const Icon(Icons.privacy_tip),
            onTap: () {},
          ),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
