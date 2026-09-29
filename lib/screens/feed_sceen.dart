import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/common/appBar/primary_appBar.dart';
import 'package:meet_my_app_seller/providers/post_provider.dart';
import 'package:meet_my_app_seller/widgets/post/post_card.dart';
import 'package:meet_my_app_seller/widgets/post/create_post.dart'; // tomar CreatePostCard ekhane

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // dummyPosts shorashori na niye Provider theke live list nichhi
    final posts = context.watch<PostProvider>().posts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: Primary_AppBar(textColor: Colors.black),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CreatePostCard(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip('Posts', true, null),
                const SizedBox(width: 8),
                _buildFilterChip('RFQs', false, null),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (posts.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(child: Text('No post here')),
            )
          else
            ...posts.map(
              (post) => Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                child: PostCard(post: post),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, IconData? icon, {Color? iconColor, double iconSize = 16}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: label.isEmpty ? 12 : 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF101828) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? const Color(0xFF101828) : Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: iconColor),
            if (label.isNotEmpty) const SizedBox(width: 6),
          ],
          if (label.isNotEmpty)
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade800,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
