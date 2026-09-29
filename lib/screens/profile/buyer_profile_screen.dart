import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:meet_my_app_seller/models/profile/buyer_profile_model.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';

class BuyerProfileScreen extends StatefulWidget {
  final String buyerId;
  const BuyerProfileScreen({super.key, required this.buyerId});

  @override
  State<BuyerProfileScreen> createState() => _BuyerProfileScreenState();
}

class _BuyerProfileScreenState extends State<BuyerProfileScreen> {
  BuyerProfileModel? _buyer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBuyerProfile();
  }

  Future<void> _fetchBuyerProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('buyers')
          .select()
          .eq('id', widget.buyerId)
          .single();

      setState(() {
        _buyer = BuyerProfileModel.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text('Buyer Profile', style: GoogleFonts.inter()),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGold),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _fetchBuyerProfile();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
              child: const Text('Retry', style: TextStyle(color: AppTheme.textPrimary)),
            ),
          ],
        ),
      );
    }

    if (_buyer == null) {
      return const Center(child: Text('Buyer not found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildHeaderSection(),
          const SizedBox(height: 24),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
                backgroundImage: _buyer!.profileImageUrl != null && _buyer!.profileImageUrl!.isNotEmpty
                    ? NetworkImage(_buyer!.profileImageUrl!)
                    : null,
                child: _buyer!.profileImageUrl == null || _buyer!.profileImageUrl!.isEmpty
                    ? Text(
                        _buyer!.initials,
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryGold,
                        ),
                      )
                    : null,
              ),
              if (_buyer!.isOnline)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _buyer!.userName,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _buyer!.customerType,
              style: GoogleFonts.inter(
                color: AppTheme.secondaryGold,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.monetization_on_outlined, 'Credits', '${_buyer!.credits}'),
          const Divider(height: 24),
          _buildInfoRow(Icons.local_fire_department_outlined, 'Active Level', _buyer!.activeLevel),
          const Divider(height: 24),
          _buildInfoRow(Icons.location_on_outlined, 'Address', _buyer!.address),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryGold, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  color: const Color(0xFF6B7280),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
