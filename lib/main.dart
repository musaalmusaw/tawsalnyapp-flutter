// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';

void main() {
  runApp(const TawsalnyApp());
}

class TawsalnyApp extends StatelessWidget {
  const TawsalnyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tawsalny App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // الشاشة الرئيسية هي شاشة اختيار الدور (عميل أو سائق)
      home: const RoleSelectionScreen(),
    );
  }
}