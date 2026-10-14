import 'package:flutter/material.dart';

import '../services/ai_provider_service.dart';

/// Choose the mood classifier; cloud options need the user's API key.
class AiSigninScreen extends StatefulWidget {
  const AiSigninScreen({super.key});

  @override
  State<AiSigninScreen> createState() => _AiSigninScreenState();
}

class _AiSigninScreenState extends State<AiSigninScreen> {
  final _service = AiProviderService.instance;
  final _keyController = TextEditingController();
  AiProvider? _selected;
  AiProvider _editing = AiProvider.gemini;
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final selected = await _service.selected();
    final hasKey = (await _service.apiKey(_editing))?.isNotEmpty ?? false;
    if (mounted) {
      setState(() {
        _selected = selected;
        _hasKey = hasKey;
      });
    }
  }

  Future<void> _pickEditing(AiProvider p) async {
    _keyController.clear();
    setState(() => _editing = p);
    await _load();
  }

  Future<void> _signIn() async {
    if (_keyController.text.trim().isEmpty) return;
    await _service.signIn(_editing, _keyController.text);
    _keyController.clear();
    await _load();
  }

  Future<void> _signOut() async {
    await _service.signOut(_editing);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
        final keyUrl = _editing == AiProvider.gemini
        ? 'aistudio.google.com/apikey'
        : 'platform.openai.com/api-keys';
    return Scaffold(
      appBar: AppBar(title: const Text('Mood classifier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Active: ${_selected?.label ?? 'none'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Your photos are sent to the provider you sign in to, '
            'and usage is billed to your API key.',
          ),
          const SizedBox(height: 16),
          SegmentedButton<AiProvider>(
            segments: [
              for (final p in AiProvider.values)
                ButtonSegment(value: p, label: Text(p.label)),
            ],
            selected: {_editing},
            onSelectionChanged: (s) => _pickEditing(s.first),
          ),
          const SizedBox(height: 16),
          Text(
            "${_editing.label} accounts can't be linked to apps directly, "
            'so sign in with your own API key ($keyUrl). '
            'It is stored in secure storage on this device.',
          ),
          const SizedBox(height: 12),
          if (_hasKey)
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text('Signed in to ${_editing.label}'),
              subtitle: _selected == _editing
                  ? const Text('Active')
                  : const Text('Saved, not active'),
              trailing: TextButton(
                onPressed: _signOut,
                child: const Text('Sign out'),
              ),
            )
          else ...[
            TextField(
              controller: _keyController,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'API key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign in & use ${_editing.label}'),
            ),
          ],
        ],
      ),
    );
  }
}
