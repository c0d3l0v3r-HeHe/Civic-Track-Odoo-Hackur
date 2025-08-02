import 'dart:math' show cos, sin, sqrt, atan2, pi;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/report.dart';
import '../models/issue_category.dart';
import '../models/report_status.dart';

class ReportService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String _collection = 'reports';

  // Create a new report
  static Future<String> createReport({
    required String title,
    required String description,
    required IssueCategory category,
    required double latitude,
    required double longitude,
    String? location,
    List<String> imageUrls = const [],
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final docRef = _firestore.collection(_collection).doc();

      final initialLog = StatusChangeLog(
        id: '${docRef.id}_log_1',
        fromStatus: ReportStatus.submitted,
        toStatus: ReportStatus.submitted,
        changedBy: user.uid,
        changedByName:
            user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
        timestamp: now,
        reason: 'Initial report submission',
      );

      final report = Report(
        id: docRef.id,
        title: title,
        description: description,
        reporterUserId: user.uid,
        reporterUserName:
            user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
        reporterUserImage: user.photoURL,
        imageUrls: imageUrls,
        category: category,
        status: ReportStatus.submitted,
        createdAt: now,
        updatedAt: now,
        location: location,
        latitude: latitude,
        longitude: longitude,
        statusHistory: [initialLog],
        upvotedBy: [],
        downvotedBy: [],
      );

      final reportData = report.toJson();
      reportData['isFlagged'] =
          false; // Explicitly set isFlagged to false for new reports

      await docRef.set(reportData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  // Get reports within a certain radius (in kilometers)
  static Future<List<Report>> getReportsWithinRadius({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    try {
      // For simplicity, we'll use a bounding box instead of precise circular radius
      // This is more efficient for Firestore queries
      const double kmPerDegree = 111.0; // Approximate km per degree of latitude
      final double latDelta = radiusKm / kmPerDegree;

      final query = await _firestore
          .collection(_collection)
          .where('latitude', isGreaterThanOrEqualTo: centerLat - latDelta)
          .where('latitude', isLessThanOrEqualTo: centerLat + latDelta)
          .orderBy('createdAt', descending: true)
          .get();

      final reports = <Report>[];
      for (final doc in query.docs) {
        try {
          final data = doc.data();

          // Skip flagged reports
          if (data['isFlagged'] == true) {
            continue;
          }

          final report = Report.fromJson({...data, 'id': doc.id});

          // Double-check with more precise distance calculation
          final distance = _calculateDistance(
            centerLat,
            centerLng,
            report.latitude ?? 0,
            report.longitude ?? 0,
          );

          if (distance <= radiusKm) {
            reports.add(report);
          }
        } catch (e) {
          print('Error parsing report ${doc.id}: $e');
        }
      }

      return reports;
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  // Get all reports for testing
  static Future<List<Report>> getAllReports() async {
    try {
      print('Fetching all reports from Firestore...');
      final query = await _firestore
          .collection(_collection)
          .where('isFlagged', isNotEqualTo: true) // Filter out flagged reports
          .orderBy('isFlagged') // Required for inequality filter
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${query.docs.length} documents in Firestore');

      final reports = <Report>[];
      for (final doc in query.docs) {
        try {
          final report = Report.fromJson({...doc.data(), 'id': doc.id});
          reports.add(report);
          print('Successfully parsed report: ${report.id} - ${report.title}');
        } catch (e) {
          print('Error parsing report ${doc.id}: $e');
        }
      }

      print('Returning ${reports.length} reports');
      return reports;
    } catch (e) {
      print('Error fetching all reports: $e');
      throw Exception('Failed to fetch reports: $e');
    }
  }

  // Update report status (admin function)
  static Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus newStatus,
    String? reason,
    String? adminNotes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = _firestore.collection(_collection).doc(reportId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        throw Exception('Report not found');
      }

      final currentReport = Report.fromJson({
        ...docSnapshot.data()!,
        'id': reportId,
      });

      final newLog = StatusChangeLog(
        id: '${reportId}_log_${currentReport.statusHistory.length + 1}',
        fromStatus: currentReport.status,
        toStatus: newStatus,
        changedBy: user.uid,
        changedByName: user.displayName ?? user.email?.split('@')[0] ?? 'Admin',
        timestamp: DateTime.now(),
        reason: reason,
        adminNotes: adminNotes,
      );

      final updatedReport = currentReport.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        statusHistory: [...currentReport.statusHistory, newLog],
      );

      await docRef.update(updatedReport.toJson());
    } catch (e) {
      throw Exception('Failed to update report status: $e');
    }
  }

  // Vote on a report
  static Future<void> voteOnReport({
    required String reportId,
    required bool isUpvote,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final docRef = _firestore.collection(_collection).doc(reportId);

      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(docRef);

        if (!docSnapshot.exists) {
          throw Exception('Report not found');
        }

        final report = Report.fromJson({
          ...docSnapshot.data()!,
          'id': reportId,
        });

        List<String> upvotedBy = List.from(report.upvotedBy);
        List<String> downvotedBy = List.from(report.downvotedBy);

        // Remove user from both lists first
        upvotedBy.remove(user.uid);
        downvotedBy.remove(user.uid);

        // Add to appropriate list
        if (isUpvote) {
          upvotedBy.add(user.uid);
        } else {
          downvotedBy.add(user.uid);
        }

        final updatedReport = report.copyWith(
          upvotes: upvotedBy.length,
          downvotes: downvotedBy.length,
          upvotedBy: upvotedBy,
          downvotedBy: downvotedBy,
          updatedAt: DateTime.now(),
        );

        transaction.update(docRef, updatedReport.toJson());
      });
    } catch (e) {
      throw Exception('Failed to vote on report: $e');
    }
  }

  // Calculate distance between two points using Haversine formula
  static double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLng = _degreesToRadians(lng2 - lng1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  // Create sample data for testing
  static Future<void> createSampleReports() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Sample locations around a central point (you can adjust these)
      final sampleReports = [
        {
          'title': 'Large Pothole on Main Street',
          'description':
              'Dangerous pothole causing vehicle damage near the intersection',
          'category': IssueCategory.roads,
          'latitude': 28.6139, // Delhi coordinates as example
          'longitude': 77.2090,
          'location': 'Main Street & Oak Avenue',
        },
        {
          'title': 'Broken Street Light',
          'description':
              'Street light has been flickering for weeks, completely dark at night',
          'category': IssueCategory.lighting,
          'latitude': 28.6149,
          'longitude': 77.2080,
          'location': 'Park Road near Metro Station',
        },
        {
          'title': 'Water Pipe Leak',
          'description': 'Major water leak causing flooding on the sidewalk',
          'category': IssueCategory.waterSupply,
          'latitude': 28.6129,
          'longitude': 77.2100,
          'location': 'Residential Area Block A',
        },
        {
          'title': 'Overflowing Garbage Bin',
          'description':
              'Garbage bin has been overflowing for days, attracting pests',
          'category': IssueCategory.cleanliness,
          'latitude': 28.6159,
          'longitude': 77.2070,
          'location': 'Market Square',
        },
      ];

      for (final sample in sampleReports) {
        await createReport(
          title: sample['title'] as String,
          description: sample['description'] as String,
          category: sample['category'] as IssueCategory,
          latitude: sample['latitude'] as double,
          longitude: sample['longitude'] as double,
          location: sample['location'] as String,
        );
      }
    } catch (e) {
      print('Error creating sample reports: $e');
    }
  }

  // Flag a report as inappropriate
  static Future<void> flagReport({
    required String reportId,
    required String reason,
  }) async {
    try {
      print('Flagging report: $reportId with reason: $reason');
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();

      // Add to flagged reports collection
      await _firestore.collection('flagged_reports').doc(reportId).set({
        'reportId': reportId,
        'flaggedBy': user.uid,
        'flaggedByName':
            user.displayName ?? user.email?.split('@')[0] ?? 'Anonymous',
        'flagReason': reason,
        'flaggedAt': Timestamp.fromDate(now),
      });

      print('Added to flagged_reports collection');

      // Update the report document to mark it as flagged
      await _firestore.collection(_collection).doc(reportId).update({
        'isFlagged': true,
        'flagReason': reason,
        'flaggedAt': Timestamp.fromDate(now),
        'flaggedBy': user.uid,
        'updatedAt': Timestamp.fromDate(
          now,
        ), // Add this line to update the timestamp
      });

      print('Updated report document with isFlagged: true');
    } catch (e) {
      print('Error flagging report: $e');
      rethrow;
    }
  }
}
