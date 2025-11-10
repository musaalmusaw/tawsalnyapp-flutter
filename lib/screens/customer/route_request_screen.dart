// lib/screens/customer/route_request_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// **********************************************
// ** هذا هو الرابط الذي قمنا بتعديله في آخر خطوة **
// **********************************************
// نستخدم final بدلاً من const هنا للتأكد من عدم وجود مشاكل، على الرغم من أنه يجب أن يكون ثابتًا
final url = 'https://tawsalny-match-final-2025.vercel.app/api/match-route';

class RouteRequestScreen extends StatefulWidget {
  const RouteRequestScreen({super.key});

  @override
  State<RouteRequestScreen> createState() => _RouteRequestScreenState();
}

class _RouteRequestScreenState extends State<RouteRequestScreen> {
  bool _isSearching = false;
  String _matchResult = "اضغط للبحث عن سائق";

  // دالة البحث عن السائق (تستدعي خوارزمية Vercel)
  Future<void> searchForDriver() async {
    setState(() {
      _isSearching = true;
      _matchResult = "جاري البحث عن سائق...";
    });

    try {
      // بيانات الطلب التي ترسلها الخوارزمية (يمكنك تعديل هذه البيانات)
      final body = json.encode({
        "riderId": "customer_12345",
        "pickupLat": 33.3152,      // مثال إحداثيات انطلاق
        "pickupLng": 44.3661,
        "destinationLat": 33.3121, // مثال إحداثيات وصول
        "destinationLng": 44.3644,
        "radiusKm": 5,             // نصف قطر البحث عن السائقين
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['matchedDriver']) {
          setState(() {
            _matchResult = "تم العثور على سائق! السائق: ${data['driverId']}";
          });
        } else {
          setState(() {
            _matchResult = "لم يتم العثور على سائق قريب. حاول مرة أخرى.";
          });
        }
      } else {
        // إذا كان هناك خطأ من الخادم (مثل 500)
        setState(() {
          _matchResult = "خطأ في الاتصال بالخادم: ${response.statusCode}";
        });
        print("Vercel API Error: ${response.body}");
      }
    } catch (e) {
      // إذا كان هناك خطأ في الاتصال (مثل عدم وجود إنترنت)
      setState(() {
        _matchResult = "خطأ في الشبكة أو الاتصال: $e";
      });
      print("Network Error: $e");
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب رحلة')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              _matchResult,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: _isSearching ? null : searchForDriver,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: _isSearching
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('البحث عن سائق (SearchForDriver)'),
            ),
          ],
        ),
      ),
    );
  }
}