/**
 * كود خوارزمية المطابقة (JavaScript) - معدّل لـ Vercel Functions
 * يرجى لصق هذا الكود بالكامل في ملف api/match-route.js
 */

// استيراد المكتبات الضرورية
const admin = require('firebase-admin');

// 🚨 الخطوة 1: استخراج المتغيرات البيئية
const serviceAccountKeyString = process.env.SERVICE_ACCOUNT_KEY;
const databaseUrl = process.env.FIREBASE_DATABASE_URL;

let isFirebaseInitialized = false;

// يجب تهيئة التطبيق قبل استخدام خدمات Firebase الأخرى
if (!admin.apps.length) {
    if (!serviceAccountKeyString || !databaseUrl) {
        // نكتفي بالتسجيل في console ولا نرمي خطأ
        console.error("Critical Error: Missing SERVICE_ACCOUNT_KEY or FIREBASE_DATABASE_URL environment variables.");
    } else {
        try {
            // 🚨 الخطوة 2: استخدام JSON.parse لتحويل السلسلة النصية إلى كائن JSON
            const serviceAccount = JSON.parse(serviceAccountKeyString);

            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount),
                databaseURL: databaseUrl
            });
            isFirebaseInitialized = true;
            console.log("Firebase app initialized successfully.");
        } catch (e) {
            console.error("Critical Error: Failed to parse SERVICE_ACCOUNT_KEY or initialize Firebase:", e);
        }
    }
} else {
    isFirebaseInitialized = true;
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
    // التأكد من أن Firebase مُهيأ بنجاح قبل المتابعة
    if (!isFirebaseInitialized) {
        throw new Error('Internal Error: Firebase initialization failed, cannot proceed.');
    }
    // ... بقية الكود الداخلي بدون تغيير ...

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
        // استخدام Realtime Database للوصول إلى 'drivers'
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
            // استخدام Realtime Database للتحديث
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
    // التحقق من حالة التهيئة في كل طلب
    if (!isFirebaseInitialized) {
        return res.status(500).json({ error: 'Internal Server Error: Firebase initialization failed due to missing or invalid environment variables.' });
    }

    if (req.method !== 'POST') {
        // هذا الخطأ هو الذي ظهر في المتصفح قبل 502
        return res.status(405).send('Method Not Allowed');
    }

    // نحصل على البيانات ونضمن وجود حقل المصادقة
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
        // نحدد حالة الخطأ
        const statusCode = error.message.includes('Unauthenticated') || error.message.includes('Missing UID') ? 401 : 500;
        // نضمن أننا نرسل استجابة JSON صالحة
        return res.status(statusCode).json({ error: error.message });
    }
};