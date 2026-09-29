import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet_my_app_seller/screens/seller/seller_order_details_screen.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:meet_my_app_seller/screens/profile/buyer_profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _kGold = AppTheme.primaryGold;
const _kBg = Color(0xFFF5F6FA);
const _kTextPrimary = Color(0xFF1A1A2E);
const _kTextSecondary = Color(0xFF8888A0);
const _kDanger = Color(0xFFFF4D6A);
const _kWarning = Color(0xFFF6A825);
const _kBorder = Color(0xFFE8E8F0);

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  int _selectedTabIndex = 0;
  
  final List<String> _tabs = ['New', 'Processing', 'Shipped', 'Completed'];
  final List<int> _tabCounts = [3, 12, 4, 85];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildSummaryRow(),
            _buildTabs(),
            _buildAlertBanner(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _buildOrderCard(
                    orderId: 'MMP-2048',
                    isNew: true,
                    customerName: 'Rahman Trading Co',
                    customerInitials: 'RH',
                    rating: 4.8,
                    productName: 'Dell Inspiron 15',
                    units: 10,
                    unitPrice: 45000,
                    totalPrice: 450000,
                    deadlineText: 'Ship by: Today 6:00 PM',
                    isUrgent: true,
                    buyerNote: 'Need custom packaging for corporate gifting. Please ensure no price tags.',
                    actions: ['Accept Order', 'Reject'],
                  ),
                  const SizedBox(height: 16),
                  _buildOrderCard(
                    orderId: 'MMP-2047',
                    isNew: true,
                    customerName: 'Global Trade BD',
                    customerInitials: 'GT',
                    rating: 0.0,
                    productName: 'Samsung Galaxy A55',
                    units: 13,
                    unitPrice: 0, 
                    totalPrice: 520000,
                    deadlineText: 'Ship by: Jun 18, 2026',
                    isUrgent: false,
                    buyerNote: null,
                    actions: ['Accept Order'],
                  ),
                  const SizedBox(height: 16),
                  _buildOrderCard(
                    orderId: 'MMP-2046',
                    isNew: true,
                    isLargeOrder: true,
                    customerName: 'Star Electronics Ltd',
                    customerInitials: 'SE',
                    rating: 0.0,
                    productName: 'Apple iPad Pro',
                    units: 20,
                    unitPrice: 0,
                    totalPrice: 2100000,
                    deadlineText: 'Ship by: Jun 22, 2026',
                    isUrgent: false,
                    buyerNote: null,
                    actions: [], 
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: _kWarning,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Orders',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _kTextPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.search, color: _kTextPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: _kTextPrimary),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSummaryStat(_tabCounts[0], 'New'),
          _buildSummaryStat(_tabCounts[1], 'Processing'),
          _buildSummaryStat(_tabCounts[2], 'Shipped'),
          _buildSummaryStat(_tabCounts[3], 'Completed'),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _kTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: _kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTabIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? _kDanger : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? _kDanger : _kTextSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? _kDanger : _kTextSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _tabCounts[index].toString(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : _kTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAlertBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF5F5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _kDanger, size: 16),
          const SizedBox(width: 8),
          const Text(
            '2 orders must be shipped by today',
            style: TextStyle(
              fontSize: 13,
              color: _kDanger,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'View >',
            style: TextStyle(
              fontSize: 13,
              color: _kDanger.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required bool isNew,
    bool isLargeOrder = false,
    required String customerName,
    required String customerInitials,
    required double rating,
    required String productName,
    required int units,
    required int unitPrice,
    required int totalPrice,
    required String deadlineText,
    required bool isUrgent,
    required String? buyerNote,
    required List<String> actions,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SellerOrderDetailsScreen(orderId: orderId),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left indicator line
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isNew ? _kDanger : _kWarning,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Order #$orderId',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: _kTextPrimary,
                          ),
                        ),
                        if (isLargeOrder)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kWarning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'LARGE ORDER',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFB37400),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.shopping_bag, size: 12, color: Color(0xFFB37400)),
                              ],
                            ),
                          )
                        else if (isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _kDanger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _kDanger,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Customer info
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: _kWarning.withOpacity(0.3),
                            child: Text(
                              customerInitials,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8C5A00),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: _kTextSecondary,
                            ),
                          ),
                          if (rating > 0) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.star, size: 12, color: _kWarning),
                            const SizedBox(width: 4),
                            Text(
                              rating.toString(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: _kTextSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Product details
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2432),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.devices, color: Colors.white54),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  productName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _kTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$units units ${unitPrice > 0 ? '• ৳${unitPrice.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}' : ''}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _kTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '৳${totalPrice.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _kTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Deadline
                    Row(
                      children: [
                        Icon(
                          isUrgent ? Icons.schedule : Icons.calendar_today,
                          size: 14,
                          color: isUrgent ? _kDanger : const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          deadlineText,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isUrgent ? _kDanger : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                    // Buyer Note
                    if (buyerNote != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF5C3C00),
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(
                                text: 'Buyer Note: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: buyerNote),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Actions
                    if (actions.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: actions.map((action) {
                          final isPrimary = action == 'Accept Order';
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: action != actions.last ? 12.0 : 0,
                              ),
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isPrimary ? _kWarning : Colors.white,
                                    border: isPrimary ? null : Border.all(color: _kDanger.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Center(
                                    child: Text(
                                      action,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isPrimary ? _kTextPrimary : _kDanger,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      // Empty space or additional button if actions is empty in UI
                      const SizedBox(height: 16),
                      InkWell(
                         onTap: () {},
                         borderRadius: BorderRadius.circular(4),
                         child: Container(
                           width: double.infinity,
                           padding: const EdgeInsets.symmetric(vertical: 12),
                           decoration: BoxDecoration(
                             color: _kWarning,
                             borderRadius: BorderRadius.circular(4),
                           ),
                           child: const Center(
                             child: Text(
                               'Accept Order',
                               style: TextStyle(
                                 fontSize: 14,
                                 fontWeight: FontWeight.bold,
                                 color: _kTextPrimary,
                               ),
                             ),
                           ),
                         ),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
