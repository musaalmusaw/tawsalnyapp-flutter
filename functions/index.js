/**
 * هذا هو الكود الكامل لخوارزمية المطابقة.
 * يرجى مسح كل محتوى ملف index.js واستبداله بهذا الكود.
 */

// استيراد المكتبات الضرورية
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// يجب تهيئة التطبيق قبل استخدام خدمات Firebase الأخرى
admin.initializeApp();

// دالة مساعد لحساب المسافة الجغرافية (بالمتر) بين نقطتين (Haversine Formula)
function calculateDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // نصف قطر الأرض بالمتر
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lon2 - lon1) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c; // المسافة بالمتر
}

// الدالة الرئيسية لوظيفة السحابة (Cloud Function)
exports.matchRouteRequest = functions.https.onCall(async (data, context) => {

    // 1. التحقق من المصادقة (Authentication)
    if (!context.auth) {
        throw new functions.https.HttpsError('unauthenticated', 'يجب أن تكون مسجلاً للدخول لتنفيذ هذا الإجراء.');
    }

    // 2. التحقق من بيانات الطلب
    const {
        originLat,
        originLon,
        destinationLat,
        destinationLon,
        serviceType // مثال: "school" أو "private"
    } = data;

    if (!originLat || !originLon || !destinationLat || !destinationLon || !serviceType) {
        throw new functions.https.HttpsError('invalid-argument', 'بيانات الطلب غير مكتملة.');
    }

    const maxSearchDistance = 5000; // نطاق البحث الأقصى حول نقطة الانطلاق (5 كم)

    try {
        // 3. قراءة بيانات السائقين المتاحين
        const driversSnapshot = await admin.firestore().collection('drivers').get();

        if (driversSnapshot.empty) {
            return { matchFound: false, message: 'لا يوجد سائقون متاحون حالياً.' };
        }

        let bestMatch = null;
        let minDistanceToOrigin = Infinity;

        // 4. حلقة تكرار للمطابقة والترتيب (Matching and Sorting)
        driversSnapshot.docs.forEach(doc => {
            const driverData = doc.data();

            // a. مطابقة نوع الخدمة (Service Type Match)
            if (driverData.serviceType !== serviceType) {
                return; // تخطي السائق إذا كان نوع الخدمة غير مطابق
            }

            // b. التحقق من حالة السائق (Driver Status)
            if (driverData.isAvailable !== true || driverData.isBusy === true) {
                return; // تخطي السائق غير المتاح أو المشغول
            }

            // c. حساب المسافة إلى نقطة انطلاق العميل
            const driverLat = driverData.currentLocation.latitude;
            const driverLon = driverData.currentLocation.longitude;

            const distanceToOrigin = calculateDistance(
                originLat,
                originLon,
                driverLat,
                driverLon
            );

            // d. تطبيق نطاق البحث
            if (distanceToOrigin > maxSearchDistance) {
                return; // تخطي السائق البعيد جداً عن نقطة الانطلاق
            }

            // e. اختيار أفضل تطابق (الأقرب إلى نقطة انطلاق العميل)
            if (distanceToOrigin < minDistanceToOrigin) {
                minDistanceToOrigin = distanceToOrigin;
                bestMatch = {
                    driverId: doc.id,
                    distanceMeters: distanceToOrigin,
                    driverData: driverData
                };
            }
        }); // نهاية حلقة السائقين

        // 5. إرجاع النتيجة
        if (bestMatch) {
            // إضافة الطلب إلى قائمة انتظار السائق
            await admin.firestore().collection('drivers').doc(bestMatch.driverId).update({
                pendingRequests: admin.firestore.FieldValue.arrayUnion({
                    customerId: context.auth.uid,
                    origin: { lat: originLat, lon: originLon },
                    destination: { lat: destinationLat, lon: destinationLon },
                    timestamp: admin.firestore.FieldValue.serverTimestamp()
                }),
                isBusy: true // وضع السائق في وضع 'قيد الانتظار' مؤقتاً
            });

            return {
                matchFound: true,
                driverId: bestMatch.driverId,
                distance: bestMatch.distanceMeters,
                message: 'تم إرسال طلبك إلى أقرب سائق متاح.'
            };
        } else {
            return { matchFound: false, message: 'لم يتم العثور على سائق مناسب ضمن النطاق.' };
        }

    } catch (error) {
        console.error("خطأ في مطابقة الطلب:", error);
        throw new functions.https.HttpsError('internal', 'حدث خطأ غير متوقع أثناء معالجة الطلب.');
    }
});