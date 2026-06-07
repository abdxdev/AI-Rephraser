import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/history_entry.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static CollectionReference _historyCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('history');
  }

  static Future<List<HistoryEntry>> getHistory(String userId) async {
    try {
      final snapshot = await _historyCollection(
        userId,
      ).orderBy('timestamp', descending: true).limit(50).get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return HistoryEntry.fromJson({...data, 'id': doc.id});
      }).toList();
    } catch (e) {

      return [];
    }
  }

  static Future<void> addHistoryEntry(String userId, HistoryEntry entry) async {
    try {
      await _historyCollection(userId).doc(entry.id).set(entry.toJson());
    } catch (_) {

    }
  }

  static Future<void> deleteHistoryEntry(String userId, String entryId) async {
    try {
      await _historyCollection(userId).doc(entryId).delete();
    } catch (_) {}
  }

  static Future<void> clearHistory(String userId) async {
    try {
      final snapshot = await _historyCollection(userId).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}
  }

  static Future<void> syncLocalToCloud(
    String userId,
    List<HistoryEntry> localEntries,
  ) async {
    final batch = _firestore.batch();
    final col = _historyCollection(userId);

    for (final entry in localEntries) {
      batch.set(col.doc(entry.id), entry.toJson());
    }

    try {
      await batch.commit();
    } catch (_) {}
  }
}
