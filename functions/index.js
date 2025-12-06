const { onSchedule } = require("firebase-functions/v2/scheduler");
const { logger } = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();
const messaging = admin.messaging();

// Scheduler berjalan setiap jam 08:00 Pagi WIB
exports.dailyDeadlineChecker = onSchedule({
    schedule: "0 8 * * *", 
    timeZone: "Asia/Jakarta",
    region: "asia-southeast2", 
    maxInstances: 1, // PENGAMAN BIAYA
}, async (event) => {
    
    logger.log("Memulai pengecekan deadline harian...");

    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    // Target H-3 dan H-1
    const hMinus3 = new Date(today);
    hMinus3.setDate(today.getDate() + 3);
    
    const hMinus1 = new Date(today);
    hMinus1.setDate(today.getDate() + 1);

    await Promise.all([
        checkAndNotify(hMinus3, "H-3"),
        checkAndNotify(hMinus1, "H-1")
    ]);
    
    logger.log("Pengecekan selesai.");
});

async function checkAndNotify(targetDate, titlePrefix) {
    const start = new Date(targetDate); start.setHours(0,0,0,0);
    const end = new Date(targetDate); end.setHours(23,59,59,999);

    // Query Collection Group (Mencari di semua folder tasks)
    const tasksSnapshot = await db.collectionGroup('tasks')
        .where('isDone', '==', false)
        .where('deadline', '>=', start)
        .where('deadline', '<=', end)
        .get();

    if (tasksSnapshot.empty) return;

    const notifications = [];

    for (const doc of tasksSnapshot.docs) {
        const task = doc.data();
        
        // Validasi data
        if (!task.owner_id || !task.courseName) continue;

        try {
            // Ambil Token User
            const userDoc = await db.collection('users').doc(task.owner_id).get();
            if (userDoc.exists) {
                const fcmToken = userDoc.data().fcm_token;
                if (fcmToken) {
                    const message = {
                        token: fcmToken,
                        notification: {
                            title: `Reminder ${titlePrefix}: ${task.title}`,
                            body: `Tugas ${task.courseName} deadline ${titlePrefix === 'H-1' ? 'Besok' : '3 Hari Lagi'}!`,
                        },
                        data: { taskId: doc.id } // Data tambahan jika diklik
                    };
                    notifications.push(messaging.send(message));
                }
            }
        } catch (e) {
            logger.error(`Error pada task ${doc.id}:`, e);
        }
    }

    if (notifications.length > 0) {
        await Promise.allSettled(notifications);
        logger.log(`Terkirim ${notifications.length} notifikasi.`);
    }
}