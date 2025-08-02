import 'package:flutter/material.dart';

enum ReportStatus {
  submitted(
    'Submitted',
    'Report has been submitted and is pending review',
    Icons.send,
    Color(0xFF9E9E9E),
  ),
  underReview(
    'Under Review',
    'Report is being reviewed by administrators',
    Icons.visibility,
    Color(0xFFFF9800),
  ),
  investigating(
    'Investigating',
    'Issue is being investigated by relevant authorities',
    Icons.search,
    Color(0xFF2196F3),
  ),
  inProgress(
    'In Progress',
    'Work has started to address the issue',
    Icons.construction,
    Color(0xFFFFB347),
  ),
  resolved(
    'Resolved',
    'Issue has been successfully resolved',
    Icons.check_circle,
    Color(0xFF4CAF50),
  ),
  rejected(
    'Rejected',
    'Report was rejected after review',
    Icons.cancel,
    Color(0xFFFF5722),
  ),
  duplicate(
    'Duplicate',
    'This issue has already been reported',
    Icons.content_copy,
    Color(0xFF795548),
  ),
  needsMoreInfo(
    'Needs More Info',
    'Additional information required from reporter',
    Icons.info,
    Color(0xFF9C27B0),
  ),
  escalated(
    'Escalated',
    'Issue has been escalated to higher authorities',
    Icons.trending_up,
    Color(0xFFE91E63),
  ),
  onHold(
    'On Hold',
    'Issue resolution is temporarily on hold',
    Icons.pause,
    Color(0xFF607D8B),
  );

  const ReportStatus(this.displayName, this.description, this.icon, this.color);

  final String displayName;
  final String description;
  final IconData icon;
  final Color color;

  // Get status by name
  static ReportStatus? fromString(String name) {
    try {
      return ReportStatus.values.firstWhere(
        (status) => status.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get all statuses as a list
  static List<ReportStatus> getAllStatuses() {
    return ReportStatus.values;
  }

  // Get active statuses (not final states)
  static List<ReportStatus> getActiveStatuses() {
    return [
      ReportStatus.submitted,
      ReportStatus.underReview,
      ReportStatus.investigating,
      ReportStatus.inProgress,
      ReportStatus.needsMoreInfo,
      ReportStatus.escalated,
      ReportStatus.onHold,
    ];
  }

  // Get final statuses (completed states)
  static List<ReportStatus> getFinalStatuses() {
    return [
      ReportStatus.resolved,
      ReportStatus.rejected,
      ReportStatus.duplicate,
    ];
  }

  // Check if status is active (not completed)
  bool get isActive {
    return getActiveStatuses().contains(this);
  }

  // Check if status is final (completed)
  bool get isFinal {
    return getFinalStatuses().contains(this);
  }

  // Check if status is positive (good outcome)
  bool get isPositive {
    return this == ReportStatus.resolved;
  }

  // Check if status is negative (bad outcome)
  bool get isNegative {
    return [ReportStatus.rejected, ReportStatus.duplicate].contains(this);
  }

  // Get light version of the color for backgrounds
  Color get lightColor {
    return color.withOpacity(0.1);
  }

  // Get next possible statuses from current status
  List<ReportStatus> getNextPossibleStatuses() {
    switch (this) {
      case ReportStatus.submitted:
        return [
          ReportStatus.underReview,
          ReportStatus.rejected,
          ReportStatus.duplicate,
          ReportStatus.needsMoreInfo,
        ];
      case ReportStatus.underReview:
        return [
          ReportStatus.investigating,
          ReportStatus.rejected,
          ReportStatus.duplicate,
          ReportStatus.needsMoreInfo,
          ReportStatus.escalated,
        ];
      case ReportStatus.investigating:
        return [
          ReportStatus.inProgress,
          ReportStatus.resolved,
          ReportStatus.rejected,
          ReportStatus.escalated,
          ReportStatus.onHold,
        ];
      case ReportStatus.inProgress:
        return [
          ReportStatus.resolved,
          ReportStatus.onHold,
          ReportStatus.escalated,
        ];
      case ReportStatus.needsMoreInfo:
        return [
          ReportStatus.underReview,
          ReportStatus.investigating,
          ReportStatus.rejected,
        ];
      case ReportStatus.escalated:
        return [
          ReportStatus.investigating,
          ReportStatus.inProgress,
          ReportStatus.resolved,
          ReportStatus.onHold,
        ];
      case ReportStatus.onHold:
        return [
          ReportStatus.investigating,
          ReportStatus.inProgress,
          ReportStatus.resolved,
          ReportStatus.rejected,
        ];
      case ReportStatus.resolved:
      case ReportStatus.rejected:
      case ReportStatus.duplicate:
        return []; // Final states have no next status
    }
  }

  // Get estimated time to resolution based on status
  String getEstimatedTimeToResolve() {
    switch (this) {
      case ReportStatus.submitted:
        return '1-2 days for review';
      case ReportStatus.underReview:
        return '2-5 days for investigation';
      case ReportStatus.investigating:
        return '1-2 weeks for resolution';
      case ReportStatus.inProgress:
        return '2-4 weeks for completion';
      case ReportStatus.needsMoreInfo:
        return 'Depends on user response';
      case ReportStatus.escalated:
        return '3-6 weeks (higher priority)';
      case ReportStatus.onHold:
        return 'Indefinite (external dependencies)';
      case ReportStatus.resolved:
      case ReportStatus.rejected:
      case ReportStatus.duplicate:
        return 'Completed';
    }
  }

  @override
  String toString() => displayName;
}
