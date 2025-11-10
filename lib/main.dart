// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// **ملاحظة هامة:** تأكد من إنشاء هذه الملفات أولاً في المسارات المحددة!

// ملفات الخدمات
import 'services/user_service.dart';

// ملفات الشاشات
import 'screens/auth/role_selection_screen.dart'; // شاشة اختيار الدور (الترحيبية)
import 'screens/customer/customer_home_screen.dart'; // الشاشة الرئيسية للزبون
import 'screens/driver/driver_home_screen.dart';    // الشاشة الرئيسية للسائق

void main() async {
  // التأكد من تهيئة Flutter Widgets قبل أي عملية asynchronous
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase
  await Firebase.initializeApp();

  runApp(
    // استخدام MultiProvider لإدارة حالة التطبيق
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق طريقي',
      debugShowCheckedModeBanner: false,
      // استخدام الاتجاه من اليمين لليسار (RTL) للغة العربية
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial', // يمكنك تغيير الخط لخط عربي مثل 'Cairo' إذا أضفته
        appBarTheme: AppBarTheme(centerTitle: true),
        // لون زر التشغيل
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.deepOrange,
        ),
      ),
      // التوجيه الأولي إلى مدير المصادقة
      home: AuthWrapper(),
    );
  }
}

// **مدير المصادقة (AuthWrapper): يتحقق من حالة المستخدم ودوره**
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // شاشة تحميل عند الانتظار
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 1. إذا لم يكن المستخدم مسجل الدخول، انتقل لشاشة اختيار الدور (التسجيل)
        if (!snapshot.hasData) {
          return RoleSelectionScreen();
        }

        // 2. إذا كان مسجل الدخول، تحقق من دوره (سائق/زبون) واذهب لصفحته الرئيسية
        return FutureBuilder<String>(
          future: Provider.of<UserService>(context, listen: false).getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final role = roleSnapshot.data;
            if (role == 'driver') {
              return DriverHomeScreen();
            } else if (role == 'customer') {
              return CustomerHomeScreen();
            }

            // في حالة استثنائية: مستخدم مسجل لكن دوره غير محدد
            return RoleSelectionScreen();
          },
        );
      },
    );
  }
}