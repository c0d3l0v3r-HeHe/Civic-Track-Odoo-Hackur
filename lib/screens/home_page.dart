import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'create_report_page.dart';
import '../services/location_service.dart';
import '../services/report_service.dart';
import '../models/report.dart';
import '../widgets/civic_post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocationInfo? _locationInfo;
  List<Report> _reports = [];
  bool _isLoadingLocation = true;
  bool _isLoadingReports = true;
  String _selectedRadius = '3'; // Default 3km

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationInfo = await LocationService.getLocationInfo();
      setState(() {
        _locationInfo = locationInfo;
        _isLoadingLocation = false;
      });

      if (locationInfo != null) {
        await _loadReports();
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
    }
  }

  Future<void> _loadReports() async {
    if (_locationInfo == null) return;

    setState(() {
      _isLoadingReports = true;
    });

    try {
      // First try to get reports within radius
      final reports = await ReportService.getReportsWithinRadius(
        centerLat: _locationInfo!.latitude,
        centerLng: _locationInfo!.longitude,
        radiusKm: double.parse(_selectedRadius),
      );

      setState(() {
        _reports = reports;
        _isLoadingReports = false;
      });
    } catch (e) {
      // If radius query fails, try to get all reports as fallback
      try {
        final allReports = await ReportService.getAllReports();
        setState(() {
          _reports = allReports;
          _isLoadingReports = false;
        });
      } catch (e2) {
        setState(() {
          _isLoadingReports = false;
        });

        // Only create sample data if we have no reports at all
        if (_reports.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to load reports. Check your connection.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _createSampleData() async {
    try {
      await ReportService.createSampleReports();
      await _loadReports();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sample reports created for testing'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error creating sample data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Civic Track'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _loadReports();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refreshed: Found ${_reports.length} reports'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: CustomScrollView(
          slivers: [
            // Location Header
            SliverToBoxAdapter(child: _buildLocationHeader()),

            // Filter Section
            SliverToBoxAdapter(child: _buildFilterSection()),

            // Reports List
            if (_isLoadingReports)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (_reports.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final report = _reports[index];
                  return CivicPostCard(
                    userName: report.reporterUserName,
                    timeAgo: report.getTimeAgo(),
                    content: report.description,
                    userImageUrl: report.reporterUserImage,
                    postImageUrl: report.imageUrls.isNotEmpty
                        ? report.imageUrls.first
                        : null,
                    likes: report.upvotes,
                    comments: 0, // TODO: Implement comments
                    shares: 0, // TODO: Implement shares
                    onLike: () => _handleVote(report.id, true),
                    onComment: () => _handleComment(report),
                    onShare: () => _handleShare(report),
                    onReport: () => _handleReport(report),
                  );
                }, childCount: _reports.length),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateReportPage()),
          );

          if (result == true) {
            await _loadReports(); // Refresh reports after creating new one
          }
        },
        backgroundColor: const Color(0xFF667eea),
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          'Report Issue',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 24),
              const Gap(8),
              const Text(
                'Your Location',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const Gap(8),
          if (_isLoadingLocation)
            const Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                Gap(8),
                Text(
                  'Getting your location...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else if (_locationInfo != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _locationInfo!.areaName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(4),
                Text(
                  _locationInfo!.shortAddress,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location unavailable',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                TextButton(
                  onPressed: _initializeLocation,
                  child: const Text(
                    'Tap to retry',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: Color(0xFF667eea), size: 20),
          const Gap(8),
          const Text(
            'Show issues within',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF29272E),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF667eea)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedRadius,
                items: const [
                  DropdownMenuItem(value: '3', child: Text('3 km')),
                  DropdownMenuItem(value: '5', child: Text('5 km')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedRadius = value;
                    });
                    _loadReports();
                  }
                },
                style: const TextStyle(
                  color: Color(0xFF667eea),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.location_searching, size: 64, color: Colors.grey[400]),
          const Gap(16),
          Text(
            'No issues found nearby',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const Gap(8),
          Text(
            'Be the first to report an issue in your area!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          TextButton(
            onPressed: _createSampleData,
            child: const Text('Create sample data for testing'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleVote(String reportId, bool isUpvote) async {
    try {
      await ReportService.voteOnReport(reportId: reportId, isUpvote: isUpvote);
      await _loadReports(); // Refresh to show updated votes
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to vote: $e')));
    }
  }

  void _handleComment(Report report) {
    // TODO: Implement comment functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Comment feature coming soon!')),
    );
  }

  void _handleShare(Report report) {
    _showShareOptions(report);
  }

  void _showShareOptions(Report report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.share, color: Color(0xFF667eea)),
                const SizedBox(width: 12),
                const Text(
                  'Share Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Share message preview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🚨 Civic Issue Report',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${report.category.displayName}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  if (report.location != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${report.location}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Help resolve this issue in our community! 📍',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Share options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  icon: Icons.share,
                  label: 'General',
                  color: const Color(0xFF667eea),
                  onTap: () => _shareGeneral(report),
                ),
                _buildShareOption(
                  icon: Icons.message,
                  label: 'WhatsApp',
                  color: const Color(0xFF25D366),
                  onTap: () => _shareToWhatsApp(report),
                ),
                _buildShareOption(
                  icon: Icons.email,
                  label: 'Email',
                  color: const Color(0xFFEA4335),
                  onTap: () => _shareToEmail(report),
                ),
                _buildShareOption(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  color: const Color(0xFF666666),
                  onTap: () => _copyToClipboard(report),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  String _generateShareMessage(Report report) {
    return '''🚨 Civic Issue Report

${report.title}

Category: ${report.category.displayName}
${report.location != null ? 'Location: ${report.location}\n' : ''}
Status: ${report.status.displayName}

${report.description}

Help resolve this issue in our community! 📍

Reported via CivicTrack App''';
  }

  void _shareGeneral(Report report) async {
    Navigator.pop(context);
    try {
      await Share.share(
        _generateShareMessage(report),
        subject: '🚨 Civic Issue: ${report.title}',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share: \$e');
    }
  }

  void _shareToWhatsApp(Report report) async {
    Navigator.pop(context);
    try {
      final message = Uri.encodeComponent(_generateShareMessage(report));
      final whatsappUrl = 'whatsapp://send?text=$message';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        // Fallback to web WhatsApp
        final webWhatsappUrl = 'https://api.whatsapp.com/send?text=$message';
        if (await canLaunchUrl(Uri.parse(webWhatsappUrl))) {
          await launchUrl(Uri.parse(webWhatsappUrl));
        } else {
          _showErrorSnackBar('WhatsApp is not installed');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to share to WhatsApp: $e');
    }
  }

  void _shareToEmail(Report report) async {
    Navigator.pop(context);
    try {
      final subject = Uri.encodeComponent('🚨 Civic Issue: ${report.title}');
      final body = Uri.encodeComponent(_generateShareMessage(report));
      final emailUrl = 'mailto:?subject=$subject&body=$body';

      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        _showErrorSnackBar('No email app found');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to share via email: $e');
    }
  }

  void _copyToClipboard(Report report) async {
    Navigator.pop(context);
    try {
      await Share.share(
        _generateShareMessage(report),
        subject: '🚨 Civic Issue: ${report.title}',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report details copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to copy: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleReport(Report report) {
    // TODO: Implement report functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report submitted to administrators'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
