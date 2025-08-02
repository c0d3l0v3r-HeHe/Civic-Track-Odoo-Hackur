import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Predefined admin emails (you can expand this later)
  static const List<String> _adminEmails = [
    'admin@civictrack.com',
    'moderator@civictrack.com',
    // Add more admin emails here
  ];

  // Check if current user is admin
  static Future<bool> isCurrentUserAdmin() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      // Check if user email is in admin list
      if (_adminEmails.contains(user.email?.toLowerCase())) {
        return true;
      }

      // Check Firestore for admin status
      final adminDoc = await _firestore
          .collection('admins')
          .doc(user.uid)
          .get();

      return adminDoc.exists && adminDoc.data()?['isAdmin'] == true;
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Admin login (uses regular Firebase Auth but checks admin status)
  static Future<bool> loginAsAdmin(String email, String password) async {
    try {
      // First check if email is in admin list
      if (!_adminEmails.contains(email.toLowerCase())) {
        throw Exception('Not authorized as admin');
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Verify admin status
        final isAdmin = await isCurrentUserAdmin();
        if (!isAdmin) {
          await _auth.signOut();
          throw Exception('Not authorized as admin');
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Admin login error: $e');
      rethrow;
    }
  }

  // Get flagged/reported reports
  static Future<List<Map<String, dynamic>>> getFlaggedReports() async {
    try {
      final query = await _firestore
          .collection('reports')
          .where('isFlagged', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .get();

      return query.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      print('Error fetching flagged reports: $e');
      return [];
    }
  }

  // Ban a user
  static Future<void> banUser(String userId, String reason) async {
    try {
      await _firestore.collection('banned_users').doc(userId).set({
        'userId': userId,
        'reason': reason,
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': _auth.currentUser?.uid,
      });

      // Update user's status in users collection
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'banReason': reason,
        'bannedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error banning user: $e');
      rethrow;
    }
  }

  // Update report status
  static Future<void> updateReportStatus(
    String reportId,
    String newStatus,
    String adminNote,
  ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Admin not authenticated');

      await _firestore.collection('reports').doc(reportId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'adminNote': adminNote,
        'lastUpdatedBy': user.uid,
      });

      // Add to status history
      await _firestore
          .collection('reports')
          .doc(reportId)
          .collection('status_history')
          .add({
            'fromStatus': null, // We'd need to track previous status
            'toStatus': newStatus,
            'changedBy': user.uid,
            'changedByName': user.displayName ?? user.email ?? 'Admin',
            'timestamp': FieldValue.serverTimestamp(),
            'reason': 'Admin action',
            'adminNotes': adminNote,
          });
    } catch (e) {
      print('Error updating report status: $e');
      rethrow;
    }
  }

  // Hide/unhide report
  static Future<void> toggleReportVisibility(String reportId, bool hide) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'isHidden': hide,
        'hiddenAt': hide ? FieldValue.serverTimestamp() : null,
        'hiddenBy': hide ? _auth.currentUser?.uid : null,
      });
    } catch (e) {
      print('Error toggling report visibility: $e');
      rethrow;
    }
  }

  // Flag a report (this can be called by regular users)
  static Future<void> flagReport(String reportId, String reason) async {
    try {
      await _firestore.collection('reports').doc(reportId).update({
        'isFlagged': true,
        'flagReason': reason,
        'flaggedAt': FieldValue.serverTimestamp(),
        'flaggedBy': _auth.currentUser?.uid,
        'isHidden': true, // Auto-hide flagged reports
      });
    } catch (e) {
      print('Error flagging report: $e');
      rethrow;
    }
  }
}
