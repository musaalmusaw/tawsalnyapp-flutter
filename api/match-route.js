/**
 * كود خوارزمية المطابقة (JavaScript) - معدّل لـ Vercel Functions
 * يرجى لصق هذا الكود بالكامل في ملف api/match-route.js
 */

// استيراد المكتبات الضرورية
const admin = require('firebase-admin');

// يجب تهيئة التطبيق قبل استخدام خدمات Firebase الأخرى
if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)),
        // رابط قاعدة البيانات الصحيح
        databaseURL: "https://tawsalnyapp-default-rtdb.firebaseio.com/"
    });
}

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

// الدالة الداخلية لخوارزمية المطابقة
async function matchRouteRequestInternal(data, context) {

    if (!context.auth || !context.auth.uid) {
        throw new Error('Unauthenticated: يجب أن تكون مسجلاً للدخول لتنفيذ هذا الإجراء.');
    }

    const {
        originLat,
        originLon,
        destinationLat,
        destinationLon,
        serviceType
    } = data;

    if (!originLat || !originLon || !destinationLat || !destinationLon || !serviceType) {
        throw new Error('Invalid-argument: بيانات الطلب غير مكتملة.');
    }

    const maxSearchDistance = 5000; // نطاق البحث الأقصى حول نقطة الانطلاق (5 كم)

    try {
        // ✅ التعديل الأول: استخدام Realtime Database للوصول إلى 'drivers'
        const driversRef = admin.database().ref('drivers');
        const driversSnapshot = await driversRef.once('value');
        const driversData = driversSnapshot.val(); // نحصل على البيانات كـ Object

        if (!driversData) {
            return { matchFound: false, message: 'لا يوجد سائقون متاحون حالياً.' };
        }

        let bestMatch = null;
        let minDistanceToOrigin = Infinity;

        // نحول البيانات إلى مصفوفة للتكرار عليها
        const driverIds = Object.keys(driversData);

        driverIds.forEach(driverId => {
            const driverData = driversData[driverId];

            // تحقق من البنية المتوقعة للبيانات (يجب أن تحتوي على currentLocation)
            if (!driverData.currentLocation || typeof driverData.currentLocation.latitude === 'undefined') {
                return;
            }

            if (driverData.serviceType !== serviceType) {
                return;
            }

            // التحقق من حالة التوفر
            if (driverData.isAvailable !== true || driverData.isBusy === true) {
                return;
            }

            const driverLat = driverData.currentLocation.latitude;
            const driverLon = driverData.currentLocation.longitude;

            const distanceToOrigin = calculateDistance(
                originLat,
                originLon,
                driverLat,
                driverLon
            );

            if (distanceToOrigin > maxSearchDistance) {
                return;
            }

            if (distanceToOrigin < minDistanceToOrigin) {
                minDistanceToOrigin = distanceToOrigin;
                bestMatch = {
                    driverId: driverId,
                    distanceMeters: distanceToOrigin,
                    driverData: driverData
                };
            }
        });

        if (bestMatch) {
            // ✅ التعديل الثاني: استخدام Realtime Database للتحديث
            const newRequest = {
                customerId: context.auth.uid,
                origin: { lat: originLat, lon: originLon },
                destination: { lat: destinationLat, lon: destinationLon },
                timestamp: Date.now() // استخدام timestamp عادي لـ RTDB
            };

            // تحديث حالة السائق وإضافة الطلب في RTDB
            await driversRef.child(bestMatch.driverId).update({
                isBusy: true,
                pendingRequests: [newRequest] // RTDB تفضل مصفوفة عادية
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
        throw new Error('Internal Error: حدث خطأ غير متوقع أثناء معالجة الطلب.');
    }
}

// دالة Vercel/Node.js الرئيسية التي تتعامل مع الطلب HTTP
module.exports = async (req, res) => {
    if (req.method !== 'POST') {
        return res.status(405).send('Method Not Allowed');
    }

    const data = req.body;

    if (!data.auth || !data.auth.uid) {
        return res.status(401).json({ error: 'Unauthenticated: Missing UID in request body.' });
    }

    const context = {
        auth: { uid: data.auth.uid }
    };

    try {
        const result = await matchRouteRequestInternal(data, context);
        return res.status(200).json(result);
    } catch (error) {
        console.error("Vercel Match Error:", error.message);
        const statusCode = error.message.includes('Unauthenticated') || error.message.includes('Missing UID') ? 401 : 500;
        return res.status(statusCode).json({ error: error.message });
    }
};