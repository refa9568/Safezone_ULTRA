const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { onDocumentDeleted } = require('firebase-functions/v2/firestore');

initializeApp();

async function deleteWhere(db, collection, field, value) {
  const snap = await db.collection(collection).where(field, '==', value).get();
  if (snap.empty) return;
  const writer = db.bulkWriter();
  snap.docs.forEach((doc) => writer.delete(doc.ref));
  await writer.close();
}

/**
 * Cascades a parent deletion to every dependent Firestore document:
 * each of the parent's children, and each child's badges, quiz_results,
 * chat_messages, and notifications. Runs regardless of how the parent
 * doc was deleted (app, console, or script), unlike the in-app cascade
 * in AppState.deleteAllData() which only fires through the app's own
 * delete-account flow.
 */
exports.onParentDelete = onDocumentDeleted('parents/{parentId}', async (event) => {
  const parentId = event.params.parentId;
  const db = getFirestore();

  const childrenSnap = await db.collection('children').where('parentId', '==', parentId).get();

  for (const childDoc of childrenSnap.docs) {
    const childId = childDoc.id;
    await deleteWhere(db, 'badges', 'childId', childId);
    await deleteWhere(db, 'quiz_results', 'childId', childId);
    await deleteWhere(db, 'chat_messages', 'childId', childId);
    await deleteWhere(db, 'notifications', 'childId', childId);
    await childDoc.ref.delete();
  }

  await deleteWhere(db, 'notifications', 'parentId', parentId);
});

/**
 * Cascades a single child deletion (without a parent delete) to that
 * child's badges, quiz_results, chat_messages, and notifications.
 */
exports.onChildDelete = onDocumentDeleted('children/{childId}', async (event) => {
  const childId = event.params.childId;
  const db = getFirestore();

  await deleteWhere(db, 'badges', 'childId', childId);
  await deleteWhere(db, 'quiz_results', 'childId', childId);
  await deleteWhere(db, 'chat_messages', 'childId', childId);
  await deleteWhere(db, 'notifications', 'childId', childId);
});
