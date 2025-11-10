// lib/screens/customer/route_request_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RouteRequestScreen extends StatefulWidget {
  final LatLng initialLocation;

  const RouteRequestScreen({required this.initialLocation});

  @override
  State<RouteRequestScreen> createState() => _RouteRequestScreenState();
}

class _RouteRequestScreenState extends State<RouteRequestScreen> {
  final _startController = TextEditingController();
  final _destinationController = TextEditingController();

  // المنطق هنا:
  // 1. استخدام Google Places API لتحديد الإحداثيات من النصوص المدخلة
  // 2. استخدام Google Maps Directions API لرسم المسار (Polyline)

  // دالة إرسال الطلب (تفعل خوارزمية البحث)
  void _searchForDriver() {
    if (_startController.text.isEmpty || _destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء تحديد نقطة البداية والوجهة أولاً.')),
      );
      return;
    }

    // هنا يتم إرسال إحداثيات (البداية والوجهة والـ Polyline) إلى Firebase
    // Backend Cloud Function
    // مدة الطلب: أسبوع واحد (7 أيام).

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري البحث عن سائقين على الخط. سيتم إخطارك خلال أسبوع.')),
    );
    //   }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('طلب خط نقل')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              // حقل البداية
              TextFormField(
                controller: _startController,
                decoration: InputDecoration(
                  labelText: 'نقطة البداية',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.location_on),
                    onPressed: () {
                      // فتح خريطة صغيرة لاختيار الموقع
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              // حقل الوجهة
              TextFormField(
                controller: _destinationController,
                decoration: InputDecoration(
                  labelText: 'الوجهة',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.flag),
                    onPressed: () {
                      // فتح خريطة صغيرة لاختيار الموقع
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),

              // زر البحث
              ElevatedButton.icon(
                onPressed: _searchForDriver,
                icon: Icon(Icons.search),
                label: Text('ابحث عن سائق (مدة الطلب أسبوع)', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 55),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }