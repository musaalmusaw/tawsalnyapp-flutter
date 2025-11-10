// lib/screens/customer/customer_registration_screen.dart

import 'package:flutter/material.dart';
import '../role_selection_screen.dart'; // للعودة إلى شاشة اختيار الدور

class CustomerRegistrationScreen extends StatelessWidget {
  const CustomerRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل العميل')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'شاشة تسجيل العملاء - غير مكتملة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // يمكنك إضافة حقول لإدخال الاسم، البريد، كلمة المرور هنا
              const TextField(
                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // هنا يتم تنفيذ منطق التسجيل
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت محاولة التسجيل!')),
                  );
                },
                child: const Text('تسجيل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}