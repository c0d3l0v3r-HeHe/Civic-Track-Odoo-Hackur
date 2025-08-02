import 'package:flutter/material.dart';
import '../widgets/civic_post_card.dart';
import '../models/report.dart';
import '../models/issue_category.dart';
import '../models/report_status.dart';
import 'issue_detail_page.dart';

class CardPreviewPage extends StatelessWidget {
  const CardPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Card Preview'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card with callbacks
            CivicPostCard(
              userName: "John Civic",
              timeAgo: "2 hours ago",
              content:
                  "Just reported a pothole on Main Street. The city needs to fix this before someone gets hurt. The community deserves better infrastructure! 🚧",
              postImageUrl:
                  "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop",
              likes: 24,
              shares: 8,
              comments: 12,
              onLike: () {
                print("Liked John's post");
              },
              onComment: () {
                print("Comment on John's post");
              },
              onShare: () {
                print("Share John's post");
              },
              onReport: () {
                print("Report John's post");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),

            // Card without callbacks
            CivicPostCard(
              userName: "Sarah Community",
              timeAgo: "1 day ago",
              content:
                  "Great news! The new community park project has been approved. Thanks to everyone who signed the petition and attended the town hall meetings. This is what civic engagement looks like! 🏞️",
              likes: 156,
              shares: 43,
              comments: 28,
              onReport: () {
                print("Report Sarah's post");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),

            // Card with all functionality
            CivicPostCard(
              userName: "Mike Reporter",
              timeAgo: "3 days ago",
              content:
                  "Attended the city council meeting yesterday. They discussed the new budget allocations for public services. Here are the key points: 1) Increased funding for schools 2) New bike lanes planned 3) Better street lighting in residential areas. Democracy in action! 🗳️",
              postImageUrl:
                  "https://images.unsplash.com/photo-1577962917302-cd874c4e31d2?w=400&h=300&fit=crop",
              likes: 89,
              shares: 22,
              comments: 15,
              onLike: () {
                print("Liked Mike's post");
              },
              onComment: () {
                print("Comment on Mike's post");
              },
              onShare: () {
                print("Share Mike's post");
              },
              onReport: () {
                print("Report Mike's post");
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  IssueDetailPage(report: _createSampleReport()),
            ),
          );
        },
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.visibility, color: Colors.white),
        label: const Text(
          'View Issue Detail',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Report _createSampleReport() {
    final now = DateTime.now();
    return Report(
      id: 'report_001',
      title: 'Dangerous Pothole on Main Street',
      description:
          'There is a large pothole on Main Street near the intersection with Oak Avenue. It\'s causing damage to vehicles and could be dangerous for cyclists. The pothole has been getting worse over the past few weeks and needs immediate attention.',
      reporterUserId: 'user_123',
      reporterUserName: 'John Civic',
      reporterUserImage: null,
      imageUrls: [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=300&fit=crop',
        'https://images.unsplash.com/photo-1551818255-e6e10975cd17?w=400&h=300&fit=crop',
      ],
      category: IssueCategory.roads,
      status: ReportStatus.inProgress,
      createdAt: now.subtract(const Duration(days: 5)),
      updatedAt: now.subtract(const Duration(hours: 2)),
      location: 'Main Street & Oak Avenue, Downtown',
      latitude: 40.7128,
      longitude: -74.0060,
      statusHistory: [
        StatusChangeLog(
          id: 'log_001',
          fromStatus: ReportStatus.submitted,
          toStatus: ReportStatus.submitted,
          changedBy: 'user_123',
          changedByName: 'John Civic',
          timestamp: now.subtract(const Duration(days: 5)),
          reason: 'Initial report submission',
        ),
        StatusChangeLog(
          id: 'log_002',
          fromStatus: ReportStatus.submitted,
          toStatus: ReportStatus.underReview,
          changedBy: 'admin_001',
          changedByName: 'City Admin',
          timestamp: now.subtract(const Duration(days: 4)),
          reason: 'Report received and assigned for review',
          adminNotes: 'Assigned to infrastructure team for assessment',
        ),
        StatusChangeLog(
          id: 'log_003',
          fromStatus: ReportStatus.underReview,
          toStatus: ReportStatus.investigating,
          changedBy: 'inspector_001',
          changedByName: 'Road Inspector Mike',
          timestamp: now.subtract(const Duration(days: 2)),
          reason: 'Field inspection completed',
          adminNotes: 'Confirmed as priority repair. Scheduling work crew.',
        ),
        StatusChangeLog(
          id: 'log_004',
          fromStatus: ReportStatus.investigating,
          toStatus: ReportStatus.inProgress,
          changedBy: 'supervisor_001',
          changedByName: 'Works Supervisor Sarah',
          timestamp: now.subtract(const Duration(hours: 2)),
          reason: 'Repair work has begun',
          adminNotes: 'Expected completion: 2-3 business days',
        ),
      ],
      upvotes: 47,
      downvotes: 2,
      upvotedBy: ['user_456', 'user_789', 'user_101'],
      downvotedBy: ['user_999'],
    );
  }
}
