// lib/screens/role_selection_screen.dart

import 'package:flutter/material.dart';
// **المسار الصحيح** للملف الموجود في مجلد customer
import 'customer/customer_home_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختر دورك')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                // **تصحيح استخدام const** هنا
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
                );
              },
              child: const Text('أنا عميل (Customer)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('وظيفة السائق غير مكتملة بعد.')),
                );
              },
              child: const Text('أنا سائق (Driver)'),
            ),
          ],
        ),
      ),
    );
  }
}