import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Configurable admin emails — edit this list to add/remove admins.
 const List<String> kAdminEmails = [
  'admin@gmail.com',
  'superadmin@yourapp.com', // add more here
];

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Email/Password signup → "customers" collection ──────────────────────
  static Future<void> saveCustomer({
    required User user,
    required String name,
  }) async {
    final docRef = _db.collection('customers').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': name,
        'email': user.email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Google login → "google_users" collection ────────────────────────────
  static Future<void> saveGoogleUser({required User user}) async {
    final docRef = _db.collection('google_users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Admin check + create admin doc if needed ────────────────────────────
  static bool isAdminEmail(String email) =>
      kAdminEmails.contains(email.trim().toLowerCase());

  static Future<void> ensureAdminDoc({required User user}) async {
    final docRef = _db.collection('admins').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'email': user.email ?? '',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ── Check if a UID has an admin doc ─────────────────────────────────────
  static Future<bool> isAdminByUid(String uid) async {
    final snapshot = await _db.collection('admins').doc(uid).get();
    return snapshot.exists &&
        (snapshot.data()?['role'] == 'admin');
  }
}