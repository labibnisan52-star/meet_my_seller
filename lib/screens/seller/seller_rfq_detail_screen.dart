import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/providers/rfq_provider.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';

class SellerRfqDetailScreen extends StatefulWidget {
  final String rfqId;
  const SellerRfqDetailScreen({super.key, required this.rfqId});

  @override
  State<SellerRfqDetailScreen> createState() => _SellerRfqDetailScreenState();
}

class _SellerRfqDetailScreenState extends State<SellerRfqDetailScreen> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _priceController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submitQuote(BuildContext context) {
    final priceStr = _priceController.text;
    if (priceStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a quote price')),
      );
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid number')),
      );
      return;
    }

    context.read<RFQProvider>().submitQuote(widget.rfqId, price, _messageController.text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quote submitted successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text('RFQ Details'),
      ),
      body: Consumer<RFQProvider>(
        builder: (context, provider, child) {
          final rfq = provider.rfqs.firstWhere(
            (r) => r.rfqId == widget.rfqId,
            orElse: () => throw Exception('RFQ not found'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // RFQ Details Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            rfq.rfqId,
                            style: const TextStyle(fontWeight: FontWeight.w100, color: AppTheme.textSecondary),
                          ),
                          Text(
                            rfq.expiresIn,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        rfq.productName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDetailCol('Quantity', '${rfq.quantity} units'),
                          _buildDetailCol('Target Price', '৳${rfq.targetPrice.toStringAsFixed(0)}'),
                          _buildDetailCol('Current Status', rfq.status),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submission Form (if not closed)
                if (rfq.status != 'Closed') ...[
                  const Text(
                    'Submit Your Quote',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your Price per unit (৳)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Message to buyer (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _submitQuote(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: AppTheme.textPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      child: const Text('Submit Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }
}
