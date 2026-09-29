import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/screens/navbar.dart';
import 'package:meet_my_app_seller/screens/seller/seller_main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 48),

              // ── Logo / Brand ──────────────────────────────────────────
              _buildBrand(),

              const SizedBox(height: 48),

              // ── Tab Bar ───────────────────────────────────────────────
              _buildTabBar(),

              const SizedBox(height: 8),

              // ── Tab Views ─────────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_BuyerTab(), _SellerTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Column(
      children: [
        // Glowing golden icon
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFD4AF37),
          ),
          child: const Icon(
            Icons.handshake_rounded,
            color: Colors.black,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'MeetMyProduct',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: Color(0xFFD4AF37),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Connect. Trade. Grow.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            letterSpacing: 2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: const Color(0xFFD4AF37),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
          padding: const EdgeInsets.all(4),
          tabs: const [
            Tab(text: '🛒  Buyer'),
            Tab(text: '🏪  Seller'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Buyer Tab
// ─────────────────────────────────────────────────────────────────────────────
class _BuyerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // ── Enter as Buyer button ───────────────────────────────────
          _GoldenButton(
            label: 'Continue as Buyer',
            icon: Icons.arrow_forward_rounded,
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (_, animation, _) => const MainScreen(),
                  transitionsBuilder: (_, animation, _, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          Text(
            'Login system coming soon',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }


}

// ─────────────────────────────────────────────────────────────────────────────
// Seller Tab
// ─────────────────────────────────────────────────────────────────────────────
class _SellerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // ── Enter as Seller button ──────────────────────────────────
          _GoldenButton(
            label: 'Continue as Seller',
            icon: Icons.store_rounded,
            onTap: () {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 500),
                  pageBuilder: (_, animation, _) => const SellerMainScreen(),
                  transitionsBuilder: (_, animation, _, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position:
                            Tween<Offset>(
                              begin: const Offset(0.05, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                        child: child,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 20),
          Text(
            'Login system coming soon',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }


}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable golden CTA button
// ─────────────────────────────────────────────────────────────────────────────
class _GoldenButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _GoldenButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_GoldenButton> createState() => _GoldenButtonState();
}

class _GoldenButtonState extends State<_GoldenButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.05,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: const Color(0xFFD4AF37),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD700).withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 10),
              Icon(widget.icon, color: Colors.black, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
