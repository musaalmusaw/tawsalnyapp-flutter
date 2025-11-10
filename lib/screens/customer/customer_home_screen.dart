// lib/screens/customer/customer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart'; // لجلب الموقع الحالي

// شاشة تحديد الوجهة للخطوط (سننشئها لاحقاً)
import 'route_request_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // الموقع الافتراضي للمنطقة (مثلاً بغداد)
  static const LatLng _initialCameraPosition = LatLng(33.3152, 44.3661);
  GoogleMapController? mapController;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // دالة جلب الموقع الحالي للمستخدم
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // التحقق من تفعيل خدمة الموقع
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // عرض رسالة للمستخدم
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // لا يمكن الوصول للموقع
        return;
      }
    }

    // جلب الموقع الفعلي
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );

    setState(() {
      _currentPosition = position;
    });

    // تحريك كاميرا الخريطة إلى موقع المستخدم
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15.0 // زوم مناسب
      ),
    );
  }

  // دالة لتشغيل طلب المشوار القصير (90 ثانية)
  void _sendShortTripRequest() {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء انتظار تحديد موقعك الحالي أولاً.')),
      );
      return;
    }

    // المنطق: إرسال طلب فوري إلى Firebase (Cloud Function)
    // المدة: 90 ثانية

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إرسال طلب مشوار قصير. يبحث النظام عن سائقين قريبين لمدة 90 ثانية.')),
    );
    //   }

    // دالة الانتقال لطلب الخط (مدة الطلب أسبوع)
    void _navigateToRouteRequest() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RouteRequestScreen(
          initialLocation: _currentPosition != null
              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
              : _initialCameraPosition,
        ),
      ));
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: Text('طريقي - الخريطة')),
        body: Stack(
          children: [
            // **1. الخريطة (Google Map)**
            GoogleMap(
              onMapCreated: (controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialCameraPosition,
                zoom: 12.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),

            // **2. أيقونات الطلبات في الأسفل**
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر خط النقل (Route Request)
                    _buildServiceButton(
                      context,
                      'خط نقل',
                      Icons.route,
                      _navigateToRouteRequest,
                      Colors.deepOrange,
                    ),
                    // زر مشوار قصير (Short Trip)
                    _buildServiceButton(
                      context,
                      'مشوار قصير',
                      Icons.car_rental,
                      _sendShortTripRequest,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget _buildServiceButton(BuildContext context, String title, IconData icon, VoidCallback onTap, Color color) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: title,
            onPressed: onTap,
            backgroundColor: color,
            child: Icon(icon, size: 30),
          ),
          SizedBox(height: 5),
          Text(title, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      );
    }
  }