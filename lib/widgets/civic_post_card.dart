import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CivicPostCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final String? userImageUrl;
  final String? postImageUrl;
  final int likes;
  final int comments;
  final int shares;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onReport;

  const CivicPostCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    this.userImageUrl,
    this.postImageUrl,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with user info
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF667eea),
                backgroundImage: userImageUrl != null
                    ? NetworkImage(userImageUrl!)
                    : null,
                child: userImageUrl == null
                    ? Text(
                        userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: Color(0xFF29272E),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Gap(6),
                        const Text(
                          '•',
                          style: TextStyle(
                            color: Color(0xFFA7A5AC),
                            fontSize: 14,
                          ),
                        ),
                        const Gap(6),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: Color(0xFFA7A5AC),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showMoreOptionsMenu(context),
                icon: const Icon(
                  Icons.more_horiz,
                  color: Color(0xFFA8A6AC),
                  size: 20,
                ),
              ),
            ],
          ),
          const Gap(16),

          // Content
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF29272E),
              fontSize: 15,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),

          // Post image (if provided)
          if (postImageUrl != null) ...[
            const Gap(16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                postImageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          color: Color(0xFFA7A5AC),
                          size: 48,
                        ),
                        Gap(8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(
                            color: Color(0xFFA7A5AC),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                        color: const Color(0xFF667eea),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          const Gap(16),

          // Action buttons
          Row(
            children: [
              _buildActionButton(
                icon: Icons.thumb_up_outlined,
                count: likes,
                onTap: onLike,
                color: const Color(0xFF667eea),
              ),
              const Gap(24),
              _buildActionButton(
                icon: Icons.chat_bubble_outline,
                count: comments,
                onTap: onComment,
                color: const Color(0xFF51C878),
              ),
              const Gap(24),
              _buildActionButton(
                icon: Icons.share_outlined,
                count: shares,
                onTap: onShare,
                color: const Color(0xFFFF6B6B),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoreOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: Color(0xFFFF6B6B),
                ),
                title: const Text(
                  'Report Post',
                  style: TextStyle(
                    color: Color(0xFF29272E),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Report inappropriate or harmful content',
                  style: TextStyle(color: Color(0xFFA7A5AC), fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  onReport?.call();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.block_outlined,
                  color: Color(0xFFA7A5AC),
                ),
                title: const Text(
                  'Hide Post',
                  style: TextStyle(
                    color: Color(0xFF29272E),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: const Text(
                  'Don\'t show posts like this',
                  style: TextStyle(color: Color(0xFFA7A5AC), fontSize: 14),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Hide post functionality
                },
              ),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required int count,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const Gap(4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
