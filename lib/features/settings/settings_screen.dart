import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pakeeza_pos/core/theme/app_theme.dart';
import 'package:pakeeza_pos/data/repositories/settings_repository.dart';
import 'package:pakeeza_pos/providers/auth_provider.dart';
import 'package:pakeeza_pos/services/printer_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repo = SettingsRepository();
  final _shopName = TextEditingController();
  final _address = TextEditingController();
  final _phones = TextEditingController();
  final _footer = TextEditingController();
  String _dbPath = '';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _shopName.dispose();
    _address.dispose();
    _phones.dispose();
    _footer.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await _repo.getAll();
    final path = await _repo.getDatabasePath();
    if (!mounted) return;
    setState(() {
      _shopName.text = settings['shop_name'] ?? '';
      _address.text = settings['shop_address'] ?? '';
      _phones.text = settings['shop_phones'] ?? '';
      _footer.text = settings['receipt_footer'] ?? '';
      _dbPath = path;
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _repo.saveAll({
      'shop_name': _shopName.text.trim(),
      'shop_address': _address.text.trim(),
      'shop_phones': _phones.text.trim(),
      'receipt_footer': _footer.text.trim(),
    });
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _exportBackup() async {
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final docs = await getApplicationDocumentsDirectory();
    final backupDir = p.join(docs.path, 'PakeezaPOS', 'backups');
    final destPath = p.join(backupDir, 'pakeeza-pos-backup-$stamp.db');

    try {
      await Directory(backupDir).create(recursive: true);
      await _repo.exportDatabaseCopy(destPath);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved:\n$destPath')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final printer = PrinterService.instance;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Shop details', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          controller: _shopName,
          decoration: const InputDecoration(labelText: 'Shop name'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _address,
          decoration: const InputDecoration(labelText: 'Address'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _phones,
          decoration: const InputDecoration(labelText: 'Phone numbers'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _footer,
          decoration: const InputDecoration(labelText: 'Receipt footer'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save settings'),
        ),
        const SizedBox(height: 24),
        Text('Printer', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          color: AppColors.bgCard,
          child: ListTile(
            leading: const Icon(Icons.print_disabled, color: AppColors.orange),
            title: const Text('Not configured'),
            subtitle: Text(printer.statusMessage),
          ),
        ),
        const SizedBox(height: 24),
        Text('Data & backup', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Database: $_dbPath',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _exportBackup,
          icon: const Icon(Icons.backup),
          label: const Text('Export database backup'),
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Logout?'),
                content: const Text('You will need to login again.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              await context.read<AuthProvider>().logout();
            }
          },
          icon: const Icon(Icons.logout, color: AppColors.danger),
          label: const Text(
            'Logout',
            style: TextStyle(color: AppColors.danger),
          ),
        ),
      ],
    );
  }
}
