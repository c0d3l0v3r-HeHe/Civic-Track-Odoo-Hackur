import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class CivicCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final String? userImageUrl;
  final String? postImageUrl;
  final int likes;
  final int shares;
  final int comments;

  const CivicCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    this.userImageUrl,
    this.postImageUrl,
    this.likes = 0,
    this.shares = 0,
    this.comments = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFFF7F6FA),
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
          // User Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 48,
                width: 48,
                child: CircleAvatar(
                  backgroundImage: userImageUrl != null
                      ? NetworkImage(userImageUrl!)
                      : null,
                  backgroundColor: const Color(0xFF667eea),
                  child: userImageUrl == null
                      ? Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                      : null,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Color(0xFF29272E),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.64,
                              ),
                            ),
                            const Gap(4),
                            const Text(
                              '·',
                              style: TextStyle(
                                color: Color(0xFFA7A5AC),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.56,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                color: Color(0xFFA7A5AC),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.56,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.more_vert,
                          color: Color(0xFFA8A6AC),
                          size: 24,
                        ),
                      ],
                    ),
                    const Gap(12),
                    Text(
                      content,
                      style: const TextStyle(
                        color: Color(0xFF29272E),
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        letterSpacing: -0.56,
                      ),
                    ),
                    
                    // Post Image (if provided)
                    if (postImageUrl != null) ...[
                      const Gap(12),
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
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    
                    const Gap(16),
                    // Engagement Row
                    Row(
                      children: [
                        // Likes
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite_border,
                              color: Color(0xFFA7A5AC),
                              size: 16,
                            ),
                            const Gap(4),
                            Text(
                              likes.toString(),
                              style: const TextStyle(
                                color: Color(0xFFA7A5AC),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        // Shares
                        Row(
                          children: [
                            const Icon(
                              Icons.share_outlined,
                              color: Color(0xFFA7A5AC),
                              size: 16,
                            ),
                            const Gap(4),
                            Text(
                              shares.toString(),
                              style: const TextStyle(
                                color: Color(0xFFA7A5AC),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const Gap(16),
                        // Comments
                        Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Color(0xFFA7A5AC),
                              size: 16,
                            ),
                            const Gap(4),
                            Text(
                              comments.toString(),
                              style: const TextStyle(
                                color: Color(0xFFA7A5AC),
                                fontSize: 13,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
