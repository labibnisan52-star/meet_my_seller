import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:meet_my_app_seller/providers/notification_provider.dart';
import 'package:meet_my_app_seller/providers/dashboard_provider.dart';
import 'package:meet_my_app_seller/screens/seller/seller_add_product_screen.dart';
import 'package:meet_my_app_seller/screens/seller/seller_rfq_list_screen.dart';
import 'package:meet_my_app_seller/screens/seller/seller_orders_screen.dart';
import 'package:meet_my_app_seller/screens/seller/seller_analytics_screen.dart';
import 'package:meet_my_app_seller/providers/order_provider.dart';
import 'package:meet_my_app_seller/screens/profile/public_profile_screen.dart';
import 'package:meet_my_app_seller/screens/profile/buyer_profile_screen.dart';
import 'package:meet_my_app_seller/screens/seller/seller_abandoned_checkouts_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SellerDashboardTab extends StatelessWidget {
  final Function(int)? onNavigateTab;
  const SellerDashboardTab({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background Gradient
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppTheme.primaryGold,
              ),
            ),
            // Scrollable Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Recent Orders'),
                    const SizedBox(height: 12),
                    _buildRecentOrders(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Pending RFQ Requests'),
                    const SizedBox(height: 12),
                    _buildPendingRFQs(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PublicProfileScreen(userId: "user_123"),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    const Text(
                      'MeetMyProduct',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildTopIcon(Icons.notifications_rounded),
                      if (notificationProvider.unreadCount > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${notificationProvider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Welcome back, Sarah',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Here's what's happening today",
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  Widget _buildSummaryCard() {
    return Consumer<DashboardProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: provider.selectedDateRange,
                          icon: Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade700),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              provider.updateDateRange(newValue);
                            }
                          },
                          items: provider.dateRangeOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  if (value == provider.selectedDateRange) ...[
                                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade700),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'Net Sales',
                        value: '৳${provider.netSales.toStringAsFixed(0)}',
                        icon: Icons.assignment_rounded,
                        iconBg: AppTheme.primaryGold.withOpacity(0.15),
                        iconColor: AppTheme.secondaryGold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Net Purchase',
                        value: '৳${provider.netPurchase.toStringAsFixed(0)}',
                        icon: Icons.store_rounded,
                        iconBg: const Color(0xFFE5F3FF),
                        iconColor: const Color(0xFF3399FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        label: 'Outstanding',
                        value: '৳${provider.outstanding.toStringAsFixed(0)}',
                        icon: Icons.person_rounded, // or assignment_ind
                        iconBg: const Color(0xFFFFF0EC),
                        iconColor: const Color(0xFFFF7A59),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatItem(
                        label: 'Net Profit',
                        value: '৳${provider.netProfit.toStringAsFixed(0)}',
                        icon: Icons.money_rounded,
                        iconBg: const Color(0xFFEAF8F1),
                        iconColor: const Color(0xFF20C976),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                BkashBalanceSlider(balance: value),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionBtn(context, Icons.add_circle_outline, 'Post Product', const SellerAddProductScreen()),
            const SizedBox(width: 16),
            _buildQuickActionBtn(context, Icons.plagiarism_outlined, 'View RFQs', const SellerRfqListScreen()),
            const SizedBox(width: 16),
            _buildQuickActionBtn(context, Icons.remove_shopping_cart_outlined, 'Abandon Orders', const SellerAbandonedCheckoutsScreen()),
            const SizedBox(width: 16),
            _buildQuickActionBtn(context, Icons.local_shipping_outlined, 'Manage Orders', const SellerOrdersScreen(), targetTabIndex: 3),
            const SizedBox(width: 16),
            _buildQuickActionBtn(context, Icons.bar_chart_rounded, 'Analytics', const SellerAnalyticsScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionBtn(BuildContext context, IconData icon, String label, Widget targetScreen, {int? targetTabIndex}) {
    return InkWell(
      onTap: () {
        if (targetTabIndex != null && onNavigateTab != null) {
          onNavigateTab!(targetTabIndex);
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Column(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppTheme.primaryGold.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.secondaryGold, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F264C),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Consumer<OrderProvider>(
      builder: (context, provider, child) {
        final recentOrders = provider.recentOrders;
        
        if (recentOrders.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No recent orders.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = recentOrders[index];
            
            Color statusColor;
            Color statusBg;
            
            if (order.status.toLowerCase() == 'processing' || order.status.toLowerCase() == 'pending') {
              statusColor = AppTheme.secondaryGold;
              statusBg = AppTheme.primaryGold.withOpacity(0.15);
            } else if (order.status.toLowerCase() == 'delivered') {
              statusColor = const Color(0xFF20C976);
              statusBg = const Color(0xFFEAF8F1);
            } else if (order.status.toLowerCase() == 'shipped') {
              statusColor = const Color(0xFF3399FF);
              statusBg = const Color(0xFFE5F3FF);
            } else {
              statusColor = Colors.grey.shade700;
              statusBg = Colors.grey.shade200;
            }

            return _buildOrderCard(
              context: context,
              company: order.supplierName,
              qty: order.quantity.toString(),
              status: order.status.toUpperCase(),
              statusColor: statusColor,
              statusBg: statusBg,
              price: '৳${order.price.toStringAsFixed(0)}',
              imgUrl: order.imgUrl ?? 'https://via.placeholder.com/60',
            );
          },
        );
      },
    );
  }

  Widget _buildOrderCard({
    required BuildContext context,
    required String company,
    required String qty,
    required String status,
    required Color statusColor,
    required Color statusBg,
    required String price,
    required String imgUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(imgUrl),
                fit: BoxFit.cover,
              ),
              color: Colors.grey.shade200,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async {
                    try {
                      final response = await Supabase.instance.client
                          .from('buyers')
                          .select('id')
                          .eq('user_name', 'Global Trade')
                          .single();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BuyerProfileScreen(buyerId: response['id']),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading profile: $e')),
                        );
                      }
                    }
                  },
                  child: Text(
                    company,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF0F264C),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: $qty',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: Color(0xFF0F264C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingRFQs(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildRfqCard(
            context: context,
            company: 'Nexus Retail',
            product: 'Wireless Earbuds',
            qty: '1000',
          ),
          const SizedBox(height: 16),
          _buildRfqCard(
            context: context,
            company: 'Zenith Electronics',
            product: 'Smart Watches Series 4',
            qty: '500',
          ),
        ],
      ),
    );
  }

  Widget _buildRfqCard({
    required BuildContext context,
    required String company,
    required String product,
    required String qty,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  try {
                    final response = await Supabase.instance.client
                        .from('buyers')
                        .select('id')
                        .eq('user_name', 'Global Trade')
                        .single();
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyerProfileScreen(buyerId: response['id']),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading profile: $e')),
                      );
                    }
                  }
                },
                child: Text(
                  company,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFFB8860B),
                  ),
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade500),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            product,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF0F264C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Requested Qty: $qty',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGold,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Respond',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BkashBalanceSlider extends StatefulWidget {
  final String balance;

  const BkashBalanceSlider({super.key, required this.balance});

  @override
  State<BkashBalanceSlider> createState() => _BkashBalanceSliderState();
}

class _BkashBalanceSliderState extends State<BkashBalanceSlider> {
  bool _isRevealed = false;
  Timer? _hideTimer;

  void _toggle() {
    if (_isRevealed) return;
    setState(() {
      _isRevealed = true;
      _hideTimer?.cancel();
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isRevealed = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double height = 28;
    const double circleSize = 24;
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth > 0 && constraints.maxWidth < 120 ? constraints.maxWidth : 120;
        return GestureDetector(
          onTap: _toggle,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(height / 2),
              border: Border.all(color: AppTheme.primaryGold.withAlpha(128)),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Text layer
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isRevealed ? 8 : circleSize + 8,
                  right: _isRevealed ? circleSize + 8 : 8,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _isRevealed ? widget.balance : 'Tap for Balance',
                      key: ValueKey(_isRevealed),
                      style: TextStyle(
                        color: _isRevealed ? const Color(0xFF0F264C) : AppTheme.secondaryGold,
                        fontSize: _isRevealed ? 14 : 11,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Circle layer
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: _isRevealed ? width - circleSize - 3 : 1,
                  top: 1,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '৳',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
