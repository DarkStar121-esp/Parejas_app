import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

export const dailyProgressionTick = functions.pubsub
  .schedule("every 24 hours")
  .onRun(async (context) => {
    const couplesSnapshot = await db.collection("couples").get();
    const batch = db.batch();

    const now = new Date();

    couplesSnapshot.forEach((doc) => {
      const couple = doc.data();
      const lastActive = couple.lastActiveDate
        ? new Date(couple.lastActiveDate)
        : new Date(0);
      const diffHours = (now.getTime() - lastActive.getTime()) / (1000 * 3600);

      let streak = couple.streakDays || 0;
      if (diffHours > 48) {
        streak = 0; // Se reinicia si pasaron más de 48 hs sin jugar
      }

      let xp = (couple.xp || 0) + 5; // +5 XP Pasiva
      let level = couple.level || 1;
      let reqXp = 100 * level;

      while (xp >= reqXp) {
        xp -= reqXp;
        level++;
        reqXp = 100 * level;
      }

      batch.update(doc.ref, {
        xp: xp,
        level: level,
        streakDays: streak,
      });
    });

    await batch.commit();
    console.log("Progreso diario actualizado para todas las parejas.");
  });
