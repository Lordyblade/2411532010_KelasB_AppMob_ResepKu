import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  // Mengambil tema yang sedang digunakan
  ThemeMode get themeMode => _themeMode;

  // Mengubah tema aplikasi
  void setThemeMode(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Memberi tahu widget bahwa tema telah berubah
    notifyListeners();
  }
}