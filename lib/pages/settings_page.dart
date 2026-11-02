import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Mode gelap'),
            subtitle: const Text(
              'Aktifkan untuk menggunakan tema gelap',
            ),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              context.read<ThemeProvider>().setThemeMode(value);
            },
            secondary: const Icon(Icons.dark_mode),
          ),
        ],
      ),
    );
  }
}