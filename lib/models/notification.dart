import 'report_status.dart';

enum NotificationType {
  statusUpdate('Status Update', 'Report status has changed'),
  newComment('New Comment', 'Someone commented on your report'),
  upvote('Upvote', 'Someone upvoted your report'),
  escalation('Escalation', 'Your report has been escalated'),
  resolution('Resolution', 'Your report has been resolved'),
  adminMessage('Admin Message', 'Administrator sent you a message');

  const NotificationType(this.title, this.description);

  final String title;
  final String description;
}

class ReportNotification {
  final String id;
  final String userId;
  final String reportId;
  final String reportTitle;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data; // Additional data like status changes

  const ReportNotification({
    required this.id,
    required this.userId,
    required this.reportId,
    required this.reportTitle,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  // Factory constructor for status update notifications
  factory ReportNotification.statusUpdate({
    required String id,
    required String userId,
    required String reportId,
    required String reportTitle,
    required ReportStatus fromStatus,
    required ReportStatus toStatus,
    required String changedByName,
    String? adminNotes,
  }) {
    return ReportNotification(
      id: id,
      userId: userId,
      reportId: reportId,
      reportTitle: reportTitle,
      type: NotificationType.statusUpdate,
      title: 'Report Status Updated',
      message: 'Your report "$reportTitle" status changed from ${fromStatus.displayName} to ${toStatus.displayName}${adminNotes != null ? '\n\nAdmin notes: $adminNotes' : ''}',
      timestamp: DateTime.now(),
      data: {
        'fromStatus': fromStatus.name,
        'toStatus': toStatus.name,
        'changedBy': changedByName,
        'adminNotes': adminNotes,
      },
    );
  }

  // Factory constructor for resolution notifications
  factory ReportNotification.resolution({
    required String id,
    required String userId,
    required String reportId,
    required String reportTitle,
    required String resolvedByName,
    String? resolutionNotes,
  }) {
    return ReportNotification(
      id: id,
      userId: userId,
      reportId: reportId,
      reportTitle: reportTitle,
      type: NotificationType.resolution,
      title: 'Report Resolved',
      message: 'Great news! Your report "$reportTitle" has been resolved by $resolvedByName.${resolutionNotes != null ? '\n\nResolution details: $resolutionNotes' : ''}',
      timestamp: DateTime.now(),
      data: {
        'resolvedBy': resolvedByName,
        'resolutionNotes': resolutionNotes,
      },
    );
  }

  // Factory constructor for escalation notifications
  factory ReportNotification.escalation({
    required String id,
    required String userId,
    required String reportId,
    required String reportTitle,
    required String escalatedByName,
    String? escalationReason,
  }) {
    return ReportNotification(
      id: id,
      userId: userId,
      reportId: reportId,
      reportTitle: reportTitle,
      type: NotificationType.escalation,
      title: 'Report Escalated',
      message: 'Your report "$reportTitle" has been escalated to higher authorities by $escalatedByName for faster resolution.${escalationReason != null ? '\n\nReason: $escalationReason' : ''}',
      timestamp: DateTime.now(),
      data: {
        'escalatedBy': escalatedByName,
        'escalationReason': escalationReason,
      },
    );
  }

  // Copy with method for marking as read
  ReportNotification copyWith({
    String? id,
    String? userId,
    String? reportId,
    String? reportTitle,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return ReportNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      reportId: reportId ?? this.reportId,
      reportTitle: reportTitle ?? this.reportTitle,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reportId': reportId,
      'reportTitle': reportTitle,
      'type': type.name,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  // Create from JSON
  factory ReportNotification.fromJson(Map<String, dynamic> json) {
    return ReportNotification(
      id: json['id'],
      userId: json['userId'],
      reportId: json['reportId'],
      reportTitle: json['reportTitle'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  // Get formatted timestamp
  String getFormattedTime() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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

  // Mark notification as read
  ReportNotification markAsRead() {
    return copyWith(isRead: true);
  }
}
