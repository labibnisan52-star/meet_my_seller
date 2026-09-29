import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/screens/seller/seller_inventory_screen.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:meet_my_app_seller/screens/feed_sceen.dart';
import 'package:meet_my_app_seller/screens/seller/seller_dashboard_tab.dart';
import 'package:meet_my_app_seller/screens/seller/seller_orders_screen.dart';
import 'package:meet_my_app_seller/screens/messages_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:meet_my_app_seller/screens/seller/seller_add_product_screen.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/providers/post_provider.dart';
import 'package:meet_my_app_seller/widgets/post/post_card.dart';
import 'package:meet_my_app_seller/widgets/post/create_post.dart';
class SellerMainScreen extends StatefulWidget {
  const SellerMainScreen({super.key});

  @override
  State<SellerMainScreen> createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    SellerDashboardTab(onNavigateTab: (index) => setState(() => _selectedIndex = index)),
    const SellerInventoryScreen(),
    const FeedScreen(),
    const SellerOrdersScreen(),
    const MessagesScreen(),
    const _SellerProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: const Border(
          top: BorderSide(color: Color(0xFFE8E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _NavItem(
                  index: 0,
                  selectedIndex: _selectedIndex,
                  icon: Icons.space_dashboard_outlined,
                  activeIcon: Icons.space_dashboard,
                  label: 'Dashboard',
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ),
              Expanded(
                child: _NavItem(
                  index: 1,
                  selectedIndex: _selectedIndex,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'Products',
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ),
              Expanded(
                child: _NavItem(
                  index: 2,
                  selectedIndex: _selectedIndex,
                  icon: Icons.explore_outlined,
                  activeIcon: Icons.explore,
                  label: 'Discover',
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ),
              Expanded(
                child: _NavItem(
                  index: 3,
                  selectedIndex: _selectedIndex,
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Orders',
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ),
              Expanded(
                child: _NavItem(
                  index: 4,
                  selectedIndex: _selectedIndex,
                  icon: Icons.message_outlined,
                  activeIcon: Icons.message,
                  label: 'Messages',
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ),
              Expanded(
                child: _NavItem(
                  index: 5,
                  selectedIndex: _selectedIndex,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: (i) => setState(() => _selectedIndex = i),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Item widget
// ─────────────────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;
    final color = isSelected ? const Color(0xFFD97706) : const Color(0xFF94A3B8);
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF5BA00).withOpacity(0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSelected ? activeIcon : icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// SELLER ORDERS/CART TAB
// ─────────────────────────────────────────────────────────────────────────────
class _SellerCartTab extends StatelessWidget {
  const _SellerCartTab();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _SellerSliverAppBar(title: 'Orders'),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All', isSelected: true),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Pending', isSelected: false),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Processing', isSelected: false),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Shipped', isSelected: false),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'Delivered', isSelected: false),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Empty state
                Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryGold.withOpacity(0.10),
                        ),
                        child: Icon(
                          Icons.inbox_rounded,
                          size: 40,
                          color: AppTheme.primaryGold.withOpacity(0.60),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'When buyers place orders, they\'ll appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _ComingSoonBanner(
                        message: 'Order management coming soon!',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SELLER PROFILE TAB
// ─────────────────────────────────────────────────────────────────────────────
class _SellerProfileTab extends StatefulWidget {
  const _SellerProfileTab();

  @override
  State<_SellerProfileTab> createState() => _SellerProfileTabState();
}

class _SellerProfileTabState extends State<_SellerProfileTab> {
  int _selectedTabIndex = 1; // Defaulting to 1 to show the Products tab as requested
  List<SellerProduct> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final supabase = Supabase.instance.client;
      
      final sellerResponse = await supabase
          .from('sellers')
          .select('id, company_name')
          .eq('company_name', 'TECHCORP BD')
          .single();
          
      final sellerId = sellerResponse['id'];
      final companyName = sellerResponse['company_name'];
      
      final productsResponse = await supabase
          .from('products')
          .select()
          .eq('seller_id', sellerId)
          .order('created_at', ascending: false);
          
      final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
      
      final List<SellerProduct> fetchedProducts = (productsResponse as List).map((p) {
        ProductStatus pStatus = ProductStatus.draft;
        switch(p['status']) {
          case 'inStock': pStatus = ProductStatus.inStock; break;
          case 'lowStock': pStatus = ProductStatus.lowStock; break;
          case 'outOfStock': pStatus = ProductStatus.outOfStock; break;
        }
        
        final priceNum = p['price'] ?? 0;
        final strikeNum = p['strikethrough_price'];
        
        return SellerProduct(
          id: p['id'].toString(),
          name: p['name'] ?? 'Unknown Product',
          category: p['category'] ?? 'Uncategorized',
          company: companyName,
          imageUrl: p['image_url'] ?? '',
          price: currencyFormat.format(priceNum),
          strikethroughPrice: strikeNum != null ? currencyFormat.format(strikeNum) : null,
          moq: p['moq'] ?? 1,
          stock: p['stock'] ?? 0,
          status: pStatus,
        );
      }).toList();
      
      fetchedProducts.addAll([
        SellerProduct(id: 'mock_1', name: 'Dell XPS 13 Plus', category: 'Electronics', company: companyName, imageUrl: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', price: '৳185,000', strikethroughPrice: '৳200,000', moq: 1, stock: 24, status: ProductStatus.inStock),
        SellerProduct(id: 'mock_2', name: 'iPhone 15 Pro Max - 256GB', category: 'Mobile Phones', company: companyName, imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', price: '৳155,000', moq: 5, stock: 45, status: ProductStatus.inStock),
        SellerProduct(id: 'mock_3', name: 'Premium Cotton T-Shirts (Bulk)', category: 'Clothing', company: companyName, imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', price: '৳350', strikethroughPrice: '৳500', moq: 100, stock: 500, status: ProductStatus.inStock),
        SellerProduct(id: 'mock_4', name: 'Modern Ceramic Vases', category: 'Home & Garden', company: companyName, imageUrl: 'https://images.unsplash.com/photo-1613923769970-13d809a7b54a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', price: '৳1,200', moq: 20, stock: 8, status: ProductStatus.lowStock),
        SellerProduct(id: 'mock_5', name: 'Samsung Galaxy S24 Ultra', category: 'Mobile Phones', company: companyName, imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80', price: '৳145,000', moq: 2, stock: 0, status: ProductStatus.outOfStock),
      ]);
      
      setState(() {
        _products = fetchedProducts;
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
    return Container(
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFF5BA00),
            surfaceTintColor: Colors.transparent,
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Color(0xFF0F172A), size: 28),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 10,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF5BA00), width: 2),
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.0),
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Color(0xFF0F172A), size: 26),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
            pinned: true,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: _buildHeaderInfo(),
          ),
          SliverToBoxAdapter(
            child: _buildStatsCard(),
          ),
          SliverToBoxAdapter(
            child: _buildNavigationTabs(),
          ),
          if (_selectedTabIndex == 0) ...[
            SliverToBoxAdapter(
              child: _buildCreatePostWidget(),
            ),
            SliverToBoxAdapter(
              child: _buildPostsTab(),
            ),
          ] else if (_selectedTabIndex == 1) ...[
            SliverToBoxAdapter(
              child: _buildProductsTab(),
            ),
          ] else if (_selectedTabIndex == 2) ...[
            SliverToBoxAdapter(
              child: _buildDealsTab(),
            ),
          ] else if (_selectedTabIndex == 3) ...[
            SliverToBoxAdapter(
              child: _buildReviewsTab(),
            ),
          ] else if (_selectedTabIndex == 4) ...[
            SliverToBoxAdapter(
              child: _buildAboutTab(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover Photo & Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Banner Image
              Container(
                height: 176,
                width: double.infinity,
                color: const Color(0xFF0F172A),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.6,
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBq6C_kdpWa8v116rR4Xuhw1Lznfg6q_LU8_4QBjmwOiM8da0E85tdFXMcUaJHKTAzmPSh-p8xsdtHPtLD8HT9JoEcN2c-Wy-uGug3arBVJ1A887f5S4Quofz16ZONurpWp0CpdsF-FaZZ-k1m_rOB3xu_aL_C5vPWCEbvM5pomwp31THwys33z2SMEvJneScStSWn97WV56J1Nk-eSFWMAaHOTSsP2aHGknunupVbX6ArZIgfAhNeGDw',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black87,
                            Colors.black26,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Edit Cover Button
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('Edit Cover', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              // Avatar
              Positioned(
                bottom: -48,
                left: 16,
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuDbn-41aH0LtJ739sqcIJsNCjVUDI7Rznebe-23n6uI7hPMbL5bIqz4f5V83Ej3CMyvXJrKvxTeweTg7n-SRvcuIgzTLVf62NMmcyRtlOxn3dnNFJoWpt1_We1Yd6MNRy803zGrZNqeItTDFeyXpPGzs69nphAUl_QrV5Yp6e__9dFvuctaKCuovwoPPJeaoXmPCadCzslX7WIHbVl-P5MUTt2Ap_N3MAunuPGQGtR4IXQhYbJJWkyP8A',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5BA00),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, size: 14, color: Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Row for Actions (to the right of avatar)
          Padding(
            padding: const EdgeInsets.only(left: 124, right: 16, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF1E293B)),
                    label: const Text('View as Public', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16, color: Color(0xFF1E293B)),
                    label: const Text('Edit Store', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5BA00),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.share_outlined, color: Color(0xFF1E293B), size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          
          // Info Section
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Dell Technologies BD',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.verified, color: Colors.blue, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: const [
                    Text('Supplier', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.circle, size: 4, color: Color(0xFFCBD5E1)),
                    ),
                    Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                    SizedBox(width: 2),
                    Text('Tejgaon, Dhaka BD', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Trust Badges Bar
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.check_circle, color: Color(0xFFFBBF24), size: 14),
                          SizedBox(width: 4),
                          Text('Verified', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.security, color: Color(0xFF2563EB), size: 14),
                          SizedBox(width: 4),
                          Text('Trade Assured', style: TextStyle(color: Color(0xFF1D4ED8), fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.workspace_premium, color: Color(0xFFD97706), size: 14),
                          SizedBox(width: 4),
                          Text('4 YRS Supplier', style: TextStyle(color: Color(0xFF92400E), fontSize: 11, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 2)),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('247', 'PRODUCTS', const Color(0xFF0F172A)),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildStatItem('98%', 'RESPONSE', const Color(0xFF059669)),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildStatItemWithIcon('4.8', Icons.star, 'RATING', const Color(0xFFF59E0B)),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          _buildStatItemWithIcon('3.2k', Icons.bolt, 'CREDITS', const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.1),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemWithIcon(String value, IconData icon, String label, Color valueColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.1),
              ),
              const SizedBox(width: 2),
              Icon(icon, color: valueColor, size: 14),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: _selectedTabIndex == 0
                  ? _buildActiveTab(Icons.feed, 'Posts')
                  : _buildInactiveTab(Icons.feed, 'Posts'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: _selectedTabIndex == 1
                  ? _buildActiveTab(Icons.inventory_2, 'Products (247)')
                  : _buildInactiveTab(Icons.inventory_2_outlined, 'Products (247)'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 2),
              child: _selectedTabIndex == 2
                  ? _buildActiveTab(Icons.local_offer, 'Deals')
                  : _buildInactiveTab(Icons.local_offer_outlined, 'Deals'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 3),
              child: _selectedTabIndex == 3
                  ? _buildActiveTab(Icons.star, 'Reviews')
                  : _buildInactiveTab(Icons.star_outline, 'Reviews'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 4),
              child: _selectedTabIndex == 4
                  ? _buildActiveTab(Icons.info, 'About')
                  : _buildInactiveTab(Icons.info_outline, 'About'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTab(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5BA00),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F172A)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildInactiveTab(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF475569)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        // Top Search & Add Product Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                      SizedBox(width: 8),
                      Expanded(child: Text('Search store products...', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerAddProductScreen()));
                },
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5BA00),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.add, size: 16, color: Color(0xFF0F172A)),
                      SizedBox(width: 4),
                      Text('Add Product', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.tune, size: 18, color: Color(0xFF475569)),
              ),
            ],
          ),
        ),
        
        // Filter Chips Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('All (247)', true),
              const SizedBox(width: 8),
              _buildFilterChip('Laptops (118)', false),
              const SizedBox(width: 8),
              _buildFilterChip('Desktops & AIO (54)', false),
              const SizedBox(width: 8),
              _buildFilterChip('Monitors', false),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Product List
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: Color(0xFFF5BA00))),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('Error loading products: $_error', style: const TextStyle(color: Colors.red))),
          )
        else if (_products.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No products found', style: TextStyle(color: Colors.grey))),
          )
        else
          ..._products.map((p) => _buildSellerProductCard(
            title: p.name,
            specs: 'Category: ${p.category}',
            price: p.price,
            stock: p.stock.toString(),
            moq: p.moq.toString(),
            badgeText: p.status == ProductStatus.inStock ? 'In Stock' : p.status == ProductStatus.lowStock ? 'Low Stock' : p.status == ProductStatus.outOfStock ? 'Out of Stock' : 'Draft',
            badgeColor: p.status == ProductStatus.inStock ? const Color(0xFF10B981) : p.status == ProductStatus.lowStock ? const Color(0xFFD97706) : p.status == ProductStatus.outOfStock ? Colors.red : Colors.grey,
            imgUrl: p.imageUrl,
          )).toList(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text('Showing ${_products.length} products', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F172A) : Colors.white,
        border: Border.all(color: isActive ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : const Color(0xFF475569),
          fontSize: 11,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSellerProductCard({
    required String title,
    required String specs,
    required String price,
    required String stock,
    required String moq,
    required String badgeText,
    required Color badgeColor,
    required String imgUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badge
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(imgUrl, fit: BoxFit.cover, width: 80, height: 80),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.more_vert, size: 16, color: Color(0xFF94A3B8)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(specs, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Text('Stock: $stock', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text('MOQ: $moq', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, size: 6, color: Color(0xFF10B981)),
                          SizedBox(width: 4),
                          Text('Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerAddProductScreen()));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.edit, size: 12, color: Color(0xFF475569)),
                            SizedBox(width: 4),
                            Text('Edit', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRatingOverview(),
          const SizedBox(height: 16),
          _buildReviewList(),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("About Company", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF475569)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Dell Technologies BD is a leading B2B supplier specializing in high-quality industrial and tech products. "
            "With over 4 years of established presence, we are committed to delivering top-tier service, bulk pricing discounts, "
            "and secure packaging for enterprise clients across Bangladesh. Our operations are headquartered in Tejgaon, Dhaka.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Contact Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.edit, size: 18, color: Color(0xFF475569)),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text("Tejgaon Industrial Area, Dhaka", style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.email, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text("contact@delltechbd.com", style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              Text("+880 1234-567890", style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDealsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Active Deals & Coupons', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16, color: Color(0xFF0F172A)),
                label: const Text('New Deal', style: TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5BA00),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        _buildSellerDealCard(
          title: 'Enterprise Bulk Discount',
          discount: '15% OFF',
          condition: 'Min. Order: 50 Units',
          validUntil: 'Valid until Oct 30, 2026',
        ),
        _buildSellerDealCard(
          title: 'New Client Welcome',
          discount: '৳5,000 OFF',
          condition: 'First order over ৳100,000',
          validUntil: 'No expiry',
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSellerDealCard({
    required String title,
    required String discount,
    required String condition,
    required String validUntil,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(discount, style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Row(
                children: [
                  Switch(
                    value: true,
                    onChanged: (val) {},
                    activeColor: const Color(0xFF10B981),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: Color(0xFF475569)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(condition, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(validUntil, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rating
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: const [
                      Text('4.8', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                      Text(' / 5.0', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) => Icon(
                      index < 4 ? Icons.star : Icons.star_half,
                      color: const Color(0xFFF5BA00),
                      size: 14,
                    )),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Verified ratings
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 8),
                    Text('128 Verified\nRatings', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.2)),
                  ],
                ),
              ),
              // Excellent Reputation Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD1FAE5)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.verified, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 4),
                    Text('Excellent\nReputation', style: TextStyle(color: Color(0xFF059669), fontSize: 10, fontWeight: FontWeight.bold, height: 1.1)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Rating Bars
          _buildRatingBar('5★', 0.88, '88%'),
          const SizedBox(height: 6),
          _buildRatingBar('4★', 0.08, '8%'),
          const SizedBox(height: 6),
          _buildRatingBar('3★', 0.03, '3%'),
          const SizedBox(height: 6),
          _buildRatingBar('2★', 0.01, '1%'),
          const SizedBox(height: 6),
          _buildRatingBar('1★', 0.00, '0%'),
          
          const SizedBox(height: 20),
          // Stats boxes
          Row(
            children: [
              Expanded(child: _buildReviewStatBox('98%', 'Positive Feedback')),
              const SizedBox(width: 8),
              Expanded(child: _buildReviewStatBox('99%', 'Delivery Reliability')),
              const SizedBox(width: 8),
              Expanded(child: _buildReviewStatBox('15 min', 'Avg. Response')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double percent, String percentText) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 6,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF5BA00)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 24,
          child: Text(percentText, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)), textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _buildReviewStatBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    return Column(
      children: [
        _buildReviewCard(
          avatarInitial: 'TS',
          avatarColor: const Color(0xFF0F172A),
          name: 'TechServe Bangladesh Ltd.',
          buyerBadge: 'Verified B2B Buyer • 10 Orders',
          buyerBadgeColor: const Color(0xFFEFF6FF),
          buyerBadgeTextColor: const Color(0xFF2563EB),
          timeAgo: '2 days ago',
          rating: 5,
          productName: 'Dell Inspiron 15 3520 (Bulk lot x25)',
          reviewText: 'Procured 25 laptops for our engineering team onboarding. Tejgaon warehouse dispatch was completed within 24 hours with full corporate VAT challan and manufacturer warranty cards verified.',
          sellerReply: 'Thank you for your continued enterprise trust! Glad the fleet onboarding went smoothly. Let us know if you need dock accessories.',
          canReply: false,
        ),
        _buildReviewCard(
          avatarInitial: 'VS',
          avatarColor: const Color(0xFFE2E8F0),
          avatarTextColor: const Color(0xFF0F172A),
          name: 'Vertex System Solutions',
          buyerBadge: 'Trade Assured Buyer • 6 Orders',
          buyerBadgeColor: const Color(0xFFFFFBEB),
          buyerBadgeTextColor: const Color(0xFFD97706),
          timeAgo: '1 week ago',
          rating: 5,
          productName: 'Dell UltraSharp 27" 4K USB-C Hub Monitor (x6)',
          reviewText: 'Top quality IPS Black panels with pristine color accuracy. Zero dead pixels across all 6 units. Packaging was reinforced for transport.',
          sellerReply: null,
          canReply: true,
        ),
        _buildReviewCard(
          avatarInitial: 'DC',
          avatarColor: const Color(0xFF1E293B),
          name: 'DataCore Enterprise BD',
          buyerBadge: 'Enterprise Client • 3 Orders',
          buyerBadgeColor: const Color(0xFFEFF6FF),
          buyerBadgeTextColor: const Color(0xFF2563EB),
          timeAgo: '2 weeks ago',
          rating: 5,
          productName: 'Dell PowerEdge T150 Tower Server',
          reviewText: 'Solid Xeon tower server delivered pre-configured with ECC memory. Authentic Dell partner support verified via service tag.',
          sellerReply: null,
          canReply: true,
        ),
        _buildReviewCard(
          avatarInitial: 'NH',
          avatarColor: const Color(0xFFFEF3C7),
          avatarTextColor: const Color(0xFF92400E),
          name: 'Nazmul Hasan',
          buyerBadge: 'Repeat Wholesaler • Multiplan',
          buyerBadgeColor: const Color(0xFFFFFBEB),
          buyerBadgeTextColor: const Color(0xFFD97706),
          timeAgo: '3 weeks ago',
          rating: 5,
          productName: 'Dell Latitude 5430 Corporate Fleet',
          reviewText: 'Best B2B wholesale prices in Dhaka. Always reliable stock availability and instant support via DM.',
          sellerReply: 'Always a pleasure doing business with your team at Multiplan! More stocks coming in next week.',
          canReply: false,
        ),
        
        const SizedBox(height: 16),
        const Text('Showing 4 of 128 verified reviews', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextButton(
            onPressed: () {},
            child: const Text('Load More Reviews', style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildReviewCard({
    required String avatarInitial,
    required Color avatarColor,
    Color avatarTextColor = Colors.white,
    required String name,
    required String buyerBadge,
    required Color buyerBadgeColor,
    required Color buyerBadgeTextColor,
    required String timeAgo,
    required int rating,
    required String productName,
    required String reviewText,
    String? sellerReply,
    required bool canReply,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: avatarColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(avatarInitial, style: TextStyle(color: avatarTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: buyerBadgeColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(buyerBadge, style: TextStyle(color: buyerBadgeTextColor, fontSize: 9, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(timeAgo, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) => Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: const Color(0xFFF5BA00),
                  size: 12,
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Product Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 12, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(child: Text(productName, style: const TextStyle(color: Color(0xFF475569), fontSize: 10))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Review Text
          Text(
            reviewText,
            style: const TextStyle(color: Color(0xFF334155), fontSize: 12, height: 1.4),
          ),
          
          if (sellerReply != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFEF08A).withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.circle, size: 6, color: Color(0xFFF5BA00)),
                          const SizedBox(width: 6),
                          const Text('Dell Technologies BD (You)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const Text('Edit Reply', style: TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(sellerReply, style: const TextStyle(color: Color(0xFF475569), fontSize: 11, height: 1.4)),
                ],
              ),
            ),
          ],
          
          if (canReply) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5BA00),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.reply, size: 14, color: Color(0xFF0F172A)),
                        SizedBox(width: 4),
                        Text('Reply to Review', style: TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.mail_outline, size: 14, color: Color(0xFF475569)),
                        SizedBox(width: 4),
                        Text('Direct Message Buyer', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreatePostWidget() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: CreatePostCard(),
    );
  }

  Widget _buildPostsTab() {
    final posts = context.watch<PostProvider>().posts;

    if (posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('No posts yet')),
      );
    }
    
    return Column(
      children: [
        ...posts.map((post) => Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          child: PostCard(post: post),
        )),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SUB-WIDGETS

class _SellerSliverAppBar extends StatelessWidget {
  final String title;
  const _SellerSliverAppBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFFFFFFFF),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        title: Row(
          children: [
            ShaderMask(
              shaderCallback: (b) => const LinearGradient(
                colors: [AppTheme.primaryGold, AppTheme.primaryGold],
              ).createShader(b),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: Color(0xFFE8E8F0)),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: Colors.grey.shade600,
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}



class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isSelected
            ? AppTheme.primaryGold.withOpacity(0.20)
            : Colors.white.withOpacity(0.06),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryGold.withOpacity(0.50)
              : Colors.white.withOpacity(0.09),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? AppTheme.primaryGold
              : Colors.white.withOpacity(0.50),
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFFE8E8F0)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGold.withOpacity(0.80),
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ComingSoonBanner extends StatelessWidget {
  final String message;
  const _ComingSoonBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.25)),
        color: AppTheme.primaryGold.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction_rounded,
            color: AppTheme.primaryGold.withOpacity(0.60),
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: AppTheme.primaryGold.withOpacity(0.70),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


