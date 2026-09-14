import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

// 6. Cloud Scheduler: Ejecución diaria a las 00:00 UTC para XP pasiva (+5 XP)
export const dailyProgressionTick = functions.pubsub
  .schedule("0 0 * * *")
  .timeZone("UTC")
  .onRun(async (context) => {
    const couplesRef = db.collection("couples");
    const snapshot = await couplesRef.get();

    if (snapshot.empty) {
      console.log("No hay parejas registradas.");
      return null;
    }

    const batch = db.batch();

    snapshot.docs.forEach((doc) => {
      const data = doc.data();
      let currentXp = data.progression?.currentXp || 0;
      let level = data.progression?.level || 1;

      // Sumar 5 XP pasiva por día
      currentXp += 5;

      // Evaluar subida de nivel (curva: 100 * level)
      while (currentXp >= 100 * level) {
        currentXp -= 100 * level;
        level += 1;
      }

      batch.update(doc.ref, {
        "progression.currentXp": currentXp,
        "progression.level": level,
        "progression.lastPassiveTick": admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();
    console.log(`XP pasiva diaria procesada para ${snapshot.size} parejas.`);
    return null;
  });
