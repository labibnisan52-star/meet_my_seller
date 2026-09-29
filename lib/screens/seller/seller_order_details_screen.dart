import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
const _kSuccess = Color(0xFF00BFA5);

class SellerOrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const SellerOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWarning,
        elevation: 0,
        iconTheme: const IconThemeData(color: _kTextPrimary),
        title: Text(
          'Order #$orderId',
          style: GoogleFonts.outfit(
            color: _kTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildStatusBanner(),
                  _buildTimeline(),
                  const Divider(height: 1, thickness: 1, color: _kBorder),
                  _buildBuyerInformation(context),
                  const Divider(height: 1, thickness: 1, color: _kBorder),
                  _buildOrderedProducts(),
                  const Divider(height: 1, thickness: 1, color: _kBorder),
                  _buildPaymentBreakdown(),
                ],
              ),
            ),
          ),
          _buildBottomActionbar(),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFF9E5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: _kWarning,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.priority_high, size: 12, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            'Awaiting your acceptance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5C3C00),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineStep(
            label: 'Placed',
            icon: Icons.check,
            color: _kSuccess,
            isActive: false,
            isCompleted: true,
          ),
          _buildTimelineDivider(active: true),
          _buildTimelineStep(
            label: 'Accept',
            icon: Icons.circle,
            color: _kWarning,
            isActive: true,
            isCompleted: false,
            innerIcon: true,
          ),
          _buildTimelineDivider(active: false),
          _buildTimelineStep(
            label: 'Ship',
            icon: Icons.local_shipping_outlined,
            color: _kBorder,
            isActive: false,
            isCompleted: false,
          ),
          _buildTimelineDivider(active: false),
          _buildTimelineStep(
            label: 'Delivered',
            icon: Icons.inventory_2_outlined,
            color: _kBorder,
            isActive: false,
            isCompleted: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String label,
    required IconData icon,
    required Color color,
    required bool isActive,
    required bool isCompleted,
    bool innerIcon = false,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(
              color: color,
              width: isActive ? 2 : (isCompleted ? 0 : 1.5),
            ),
          ),
          child: Center(
            child: innerIcon
                ? Icon(Icons.circle, size: 10, color: color)
                : Icon(
                    icon,
                    size: 20,
                    color: isCompleted ? Colors.white : color,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
            color: isActive || isCompleted ? color : _kTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDivider({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        color: active ? _kWarning.withOpacity(0.5) : _kBorder,
        margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      ),
    );
  }

  Widget _buildBuyerInformation(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BUYER INFORMATION',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    try {
                      // Using the Global Trade test buyer for demonstration
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
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: _kBorder,
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rahman Trading Co.',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: _kTextPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'B2B Enterprise Buyer',
                              style: TextStyle(
                                fontSize: 13,
                                color: _kTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: _kBorder),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.person_outline, 'Mr. Tariq Rahman (Procurement Head)'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, '+880 1711-234567'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.email_outlined, 'tariq@rahmantrading.com.bd'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _kTextSecondary),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: _kTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderedProducts() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORDERED PRODUCTS (2)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildProductCard(
            name: 'Dell Latitude 7420 Business Laptop',
            sku: 'DL-7420-ENT',
            qty: 5,
            price: 450000,
          ),
          const SizedBox(height: 12),
          _buildProductCard(
            name: 'Sony WH-1000XM5 Wireless Headphones',
            sku: 'SNY-WH5-BLK',
            qty: 2,
            price: 82500,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String sku,
    required int qty,
    required int price,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: _kBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2432),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.computer, color: Colors.white54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: $sku | Qty: $qty',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '৳ ${price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdown() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PAYMENT BREAKDOWN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: _kTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Subtotal', '৳ 5,32,500', isBold: false),
          const SizedBox(height: 12),
          _buildPaymentRow('Shipping', 'Free', isBold: false, valueColor: _kSuccess),
          const SizedBox(height: 12),
          _buildPaymentRow('Platform Commission (3.5%)', '- ৳ 18,637', isBold: false, valueColor: _kDanger),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, thickness: 1, color: _kBorder),
          ),
          _buildPaymentRow('Net Payout', '৳ 5,13,863', isBold: true, valueColor: _kSuccess),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {required bool isBold, Color valueColor = _kTextPrimary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? _kTextPrimary : _kTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: _kBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: _kDanger.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Reject',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _kDanger,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kWarning,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Accept Order',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _kTextPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
