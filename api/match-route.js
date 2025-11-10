/**
 * كود خوارزمية المطابقة (JavaScript) - معدّل لـ Vercel Functions
 * يرجى لصق هذا الكود بالكامل في ملف api/match-route.js
 */

// استيراد المكتبات الضرورية
const admin = require('firebase-admin');

// يجب تهيئة التطبيق قبل استخدام خدمات Firebase الأخرى
// نستخدم "getApps().length" لتجنب الخطأ في Vercel إذا تم استدعاء التهيئة أكثر من مرة
if (!admin.apps.length) {
    // يجب توفير مفتاح الخدمة (Service Account) لـ Firebase في Vercel
    // سنستخدم متغير بيئة (Environment Variable) يسمى FIREBASE_SERVICE_ACCOUNT
    admin.initializeApp({
        credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)),
        // **********************************************
        // ** التعديل الذي تم: إضافة رابط قاعدة البيانات الصحيح **
        // **********************************************
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

    // 1. التحقق من المصادقة (Authentication)
    // في Vercel، نتوقع أن الـ UID قد مررناه ضمن 'context.auth.uid'
    if (!context.auth || !context.auth.uid) {
        throw new Error('Unauthenticated: يجب أن تكون مسجلاً للدخول لتنفيذ هذا الإجراء.');
    }

    // 2. التحقق من بيانات الطلب
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

    // ... بقية منطق الخوارزمية (بدون تغيير) ...

    try {
        // تستخدم الخوارزمية Firestore هنا
        const driversSnapshot = await admin.firestore().collection('drivers').get();

        if (driversSnapshot.empty) {
            return { matchFound: false, message: 'لا يوجد سائقون متاحون حالياً.' };
        }

        let bestMatch = null;
        let minDistanceToOrigin = Infinity;

        driversSnapshot.docs.forEach(doc => {
            const driverData = doc.data();

            if (driverData.serviceType !== serviceType) {
                return;
            }

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
                    driverId: doc.id,
                    distanceMeters: distanceToOrigin,
                    driverData: driverData
                };
            }
        });

        if (bestMatch) {
            // تحديث حالة السائق وإضافة الطلب
            await admin.firestore().collection('drivers').doc(bestMatch.driverId).update({
                pendingRequests: admin.firestore.FieldValue.arrayUnion({
                    customerId: context.auth.uid,
                    origin: { lat: originLat, lon: originLon },
                    destination: { lat: destinationLat, lon: destinationLon },
                    timestamp: admin.firestore.FieldValue.serverTimestamp()
                }),
                isBusy: true
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
    // Vercel Serverless Functions تتعامل مع طلبات HTTP القياسية (req, res)

    if (req.method !== 'POST') {
        return res.status(405).send('Method Not Allowed');
    }

    // نحصل على البيانات من جسم الطلب (Body)
    const data = req.body;

    // لكي يعمل كود الخوارزمية (الذي تم تصميمه لـ Firebase Functions)، نحتاج إلى محاكاة سياق 'context'
    if (!data.auth || !data.auth.uid) {
        return res.status(401).json({ error: 'Unauthenticated: Missing UID in request body.' });
    }

    const context = {
        auth: { uid: data.auth.uid } // نمرر الـ UID من جسم الطلب كمصادقة
    };

    try {
        // نستدعي دالة الخوارزمية الداخلية
        const result = await matchRouteRequestInternal(data, context);
        return res.status(200).json(result);
    } catch (error) {
        console.error("Vercel Match Error:", error.message);
        // التعامل مع الأخطاء التي ترميها الخوارزمية
        const statusCode = error.message.includes('Unauthenticated') || error.message.includes('Missing UID') ? 401 : 500;
        return res.status(statusCode).json({ error: error.message });
    }
};