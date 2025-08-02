import 'issue_category.dart';
import 'report_status.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final String reporterUserId;
  final String reporterUserName;
  final String? reporterUserImage;
  final List<String> imageUrls;
  final IssueCategory category;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? location;
  final double? latitude;
  final double? longitude;
  final List<StatusChangeLog> statusHistory;
  final int upvotes;
  final int downvotes;
  final List<String> upvotedBy;
  final List<String> downvotedBy;

  const Report({
    required this.id,
    required this.title,
    required this.description,
    required this.reporterUserId,
    required this.reporterUserName,
    this.reporterUserImage,
    required this.imageUrls,
    required this.category,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.location,
    this.latitude,
    this.longitude,
    required this.statusHistory,
    this.upvotes = 0,
    this.downvotes = 0,
    required this.upvotedBy,
    required this.downvotedBy,
  });

  // Copy with method for immutable updates
  Report copyWith({
    String? id,
    String? title,
    String? description,
    String? reporterUserId,
    String? reporterUserName,
    String? reporterUserImage,
    List<String>? imageUrls,
    IssueCategory? category,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    double? latitude,
    double? longitude,
    List<StatusChangeLog>? statusHistory,
    int? upvotes,
    int? downvotes,
    List<String>? upvotedBy,
    List<String>? downvotedBy,
  }) {
    return Report(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reporterUserId: reporterUserId ?? this.reporterUserId,
      reporterUserName: reporterUserName ?? this.reporterUserName,
      reporterUserImage: reporterUserImage ?? this.reporterUserImage,
      imageUrls: imageUrls ?? this.imageUrls,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      statusHistory: statusHistory ?? this.statusHistory,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      upvotedBy: upvotedBy ?? this.upvotedBy,
      downvotedBy: downvotedBy ?? this.downvotedBy,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reporterUserId': reporterUserId,
      'reporterUserName': reporterUserName,
      'reporterUserImage': reporterUserImage,
      'imageUrls': imageUrls,
      'category': category.name,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'statusHistory': statusHistory.map((log) => log.toJson()).toList(),
      'upvotes': upvotes,
      'downvotes': downvotes,
      'upvotedBy': upvotedBy,
      'downvotedBy': downvotedBy,
    };
  }

  // Create from JSON
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      reporterUserId: json['reporterUserId'],
      reporterUserName: json['reporterUserName'],
      reporterUserImage: json['reporterUserImage'],
      imageUrls: List<String>.from(json['imageUrls']),
      category: IssueCategory.values.firstWhere(
        (e) => e.name == json['category'],
      ),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      location: json['location'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      statusHistory: (json['statusHistory'] as List)
          .map((log) => StatusChangeLog.fromJson(log))
          .toList(),
      upvotes: json['upvotes'] ?? 0,
      downvotes: json['downvotes'] ?? 0,
      upvotedBy: List<String>.from(json['upvotedBy'] ?? []),
      downvotedBy: List<String>.from(json['downvotedBy'] ?? []),
    );
  }

  // Helper method to get time since creation
  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Helper method to check if user has upvoted
  bool hasUserUpvoted(String userId) {
    return upvotedBy.contains(userId);
  }

  // Helper method to check if user has downvoted
  bool hasUserDownvoted(String userId) {
    return downvotedBy.contains(userId);
  }
}

// Status change log for transparency
class StatusChangeLog {
  final String id;
  final ReportStatus fromStatus;
  final ReportStatus toStatus;
  final String changedBy;
  final String changedByName;
  final DateTime timestamp;
  final String? reason;
  final String? adminNotes;

  const StatusChangeLog({
    required this.id,
    required this.fromStatus,
    required this.toStatus,
    required this.changedBy,
    required this.changedByName,
    required this.timestamp,
    this.reason,
    this.adminNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromStatus': fromStatus.name,
      'toStatus': toStatus.name,
      'changedBy': changedBy,
      'changedByName': changedByName,
      'timestamp': timestamp.toIso8601String(),
      'reason': reason,
      'adminNotes': adminNotes,
    };
  }

  factory StatusChangeLog.fromJson(Map<String, dynamic> json) {
    return StatusChangeLog(
      id: json['id'],
      fromStatus: ReportStatus.values.firstWhere(
        (e) => e.name == json['fromStatus'],
      ),
      toStatus: ReportStatus.values.firstWhere(
        (e) => e.name == json['toStatus'],
      ),
      changedBy: json['changedBy'],
      changedByName: json['changedByName'],
      timestamp: DateTime.parse(json['timestamp']),
      reason: json['reason'],
      adminNotes: json['adminNotes'],
    );
  }

  String getFormattedTimestamp() {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
