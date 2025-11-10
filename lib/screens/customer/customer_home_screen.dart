// lib/screens/customer/customer_home_screen.dart

import 'package:flutter/material.dart';
import 'route_request_screen.dart'; // التوجيه لشاشة طلب الرحلة

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الصفحة الرئيسية للعميل')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'أهلاً بك أيها العميل!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                // التوجيه إلى شاشة طلب الرحلة حيث يتم استدعاء الخوارزمية
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RouteRequestScreen()),
                );
              },
              child: const Text('اطلب رحلة الآن'),
            ),
          ],
        ),
      ),
    );
  }
}