import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../services/admin_service.dart';
import '../models/issue_category.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _flaggedReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlaggedReports();
  }

  Future<void> _loadFlaggedReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await AdminService.getFlaggedReports();
      setState(() {
        _flaggedReports = reports;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reports: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateReportStatus(String reportId, String newStatus) async {
    final TextEditingController noteController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Report Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change status to: $newStatus'),
            const Gap(16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Admin Note (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await AdminService.updateReportStatus(
          reportId,
          newStatus,
          noteController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report status updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _loadFlaggedReports(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _banUser(String reportId, String userId, String userName) async {
    final TextEditingController reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ban User: $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action will permanently ban the user from the platform.',
            ),
            const Gap(16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for ban *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ban User'),
          ),
        ],
      ),
    );

    if (result == true && reasonController.text.trim().isNotEmpty) {
      try {
        await AdminService.banUser(userId, reasonController.text.trim());
        await AdminService.toggleReportVisibility(reportId, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User banned successfully'),
            backgroundColor: Colors.green,
          ),
        );

        _loadFlaggedReports(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error banning user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFlaggedReports,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Admin info header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.admin_panel_settings,
                  color: Colors.white,
                  size: 32,
                ),
                const Gap(8),
                Text(
                  'Welcome, ${user?.email ?? 'Admin'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                const Text(
                  'Manage flagged reports and user moderation',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Stats row
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.flag, color: Colors.red[600], size: 24),
                        const Gap(8),
                        Text(
                          '${_flaggedReports.length}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Flagged Reports',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Reports list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _flaggedReports.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: Colors.green),
                        Gap(16),
                        Text(
                          'No flagged reports',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(8),
                        Text(
                          'All reports are clean!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _flaggedReports.length,
                    itemBuilder: (context, index) {
                      final report = _flaggedReports[index];
                      return _buildFlaggedReportCard(report);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlaggedReportCard(Map<String, dynamic> reportData) {
    final reportId = reportData['id'] as String;
    final title = reportData['title'] as String? ?? 'Untitled';
    final description = reportData['description'] as String? ?? '';
    final reporterName = reportData['reporterUserName'] as String? ?? 'Unknown';
    final reporterUserId = reportData['reporterUserId'] as String? ?? '';
    final flagReason =
        reportData['flagReason'] as String? ?? 'No reason provided';
    final category = reportData['category'] as String? ?? 'roads';

    // Convert string category to enum
    IssueCategory issueCategory;
    try {
      issueCategory = IssueCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => IssueCategory.roads,
      );
    } catch (e) {
      issueCategory = IssueCategory.roads;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with flag indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.flag, color: Colors.red[700], size: 16),
                    const Gap(4),
                    Text(
                      'FLAGGED',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: issueCategory.lightColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      issueCategory.icon,
                      color: issueCategory.color,
                      size: 14,
                    ),
                    const Gap(4),
                    Text(
                      issueCategory.displayName,
                      style: TextStyle(
                        color: issueCategory.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Gap(12),

          // Report title
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const Gap(8),

          // Report description (truncated)
          Text(
            description.length > 100
                ? '${description.substring(0, 100)}...'
                : description,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),

          const Gap(12),

          // Reporter info
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.grey),
              const Gap(4),
              Text(
                'Reported by: $reporterName',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),

          const Gap(8),

          // Flag reason
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[600], size: 16),
                const Gap(8),
                Expanded(
                  child: Text(
                    'Flag reason: $flagReason',
                    style: TextStyle(color: Colors.red[700], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          // Action buttons
          Row(
            children: [
              // Status change dropdown
              Expanded(
                child: PopupMenuButton<String>(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 16),
                        Gap(4),
                        Text(
                          'Change Status',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  onSelected: (newStatus) =>
                      _updateReportStatus(reportId, newStatus),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'submitted',
                      child: Row(
                        children: [
                          Icon(Icons.inbox, size: 16),
                          Gap(8),
                          Text('Submitted'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'under_review',
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 16),
                          Gap(8),
                          Text('Under Review'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'in_progress',
                      child: Row(
                        children: [
                          Icon(Icons.build, size: 16),
                          Gap(8),
                          Text('In Progress'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'resolved',
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16),
                          Gap(8),
                          Text('Resolved'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'pending',
                      child: Row(
                        children: [
                          Icon(Icons.pending, size: 16),
                          Gap(8),
                          Text('Pending'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(8),

              // Ban user button
              Expanded(
                child: GestureDetector(
                  onTap: () => _banUser(reportId, reporterUserId, reporterName),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, color: Colors.white, size: 16),
                        Gap(4),
                        Text(
                          'Ban User',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
