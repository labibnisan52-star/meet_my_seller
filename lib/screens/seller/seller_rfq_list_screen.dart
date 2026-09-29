import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/providers/rfq_provider.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:meet_my_app_seller/screens/seller/seller_rfq_detail_screen.dart';

class SellerRfqListScreen extends StatelessWidget {
  const SellerRfqListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Incoming RFQs'),
      ),
      body: Consumer<RFQProvider>(
        builder: (context, rfqProvider, child) {
          final rfqs = rfqProvider.rfqs;

          if (rfqs.isEmpty) {
            return const Center(
              child: Text(
                'No RFQs available.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rfqs.length,
            itemBuilder: (context, index) {
              final rfq = rfqs[index];
              return Card(
                elevation: 0,
                color: AppTheme.cardColor,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SellerRfqDetailScreen(rfqId: rfq.rfqId),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              rfq.rfqId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryGold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: rfq.status == 'Pending' 
                                    ? AppTheme.primaryGold.withOpacity(0.15)
                                    : Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                rfq.status,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: rfq.status == 'Pending' ? AppTheme.secondaryGold : Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          rfq.productName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quantity',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${rfq.quantity} units',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Target Price',
                                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '৳${rfq.targetPrice.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
