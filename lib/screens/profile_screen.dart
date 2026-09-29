import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/card/profile_header_card.dart';
import 'package:meet_my_app_seller/common/appBar/primary_appBar.dart';
import 'package:meet_my_app_seller/data/dummy_data.dart';
import 'package:meet_my_app_seller/widgets/profile/cuopon_tab.dart';
import 'package:meet_my_app_seller/widgets/profile/order_tab.dart';
import 'package:meet_my_app_seller/widgets/profile/post_tab.dart';
import 'package:meet_my_app_seller/widgets/profile/profile_tab_bar.dart';
import 'package:meet_my_app_seller/widgets/profile/rfq_tab.dart';
import 'package:meet_my_app_seller/widgets/profile/wishlist_tab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int selectedTabIndex = 0; // 0 = Post, 1 = Orders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Primary_AppBar(textColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeaderCard(user: dummyProfile),
            const SizedBox(height: 16),
            ProfileTabBar(
              selectedIndex: selectedTabIndex,
              onTabSelected: (index) {
                setState(() {
                  selectedTabIndex = index;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return const PostTab();
      case 1:
        return const OrderTab();
      case 2:
        return const RfqTab();
      case 3:
        return const WishlistTab();
      case 4:
        return const CouponTab();

      default:
        return const PostTab();
    }
  }
}
