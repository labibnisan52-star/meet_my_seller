import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/data/dummy_data.dart';
import 'package:meet_my_app_seller/widgets/Product/Product_card.dart';
import 'package:meet_my_app_seller/widgets/cuopon/cuopon_card.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            // Viewing as Public Visitor Banner
            Container(
              color: const Color(0xFF0F172A),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFF5BA00), width: 1.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: 'Viewing as ', style: TextStyle(color: Colors.white, fontSize: 12)),
                            TextSpan(text: 'Public Visitor', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Exit', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xFFF5BA00),
                    surfaceTintColor: Colors.transparent,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    title: Text(
                      widget.userId,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Color(0xFF0F172A)),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
                        onPressed: () {},
                      ),
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
                  SliverToBoxAdapter(
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
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
              // Avatar
              Positioned(
                bottom: -48,
                left: 16,
                child: Container(
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
                  flex: 3,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, size: 16, color: Color(0xFF1E293B)),
                    label: const Text('Follow', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade200),
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.mail_outline, size: 16, color: Color(0xFF1E293B)),
                    label: const Text('Message', style: TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.bold)),
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
                  children: [
                    Text(
                      widget.userId,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.verified, color: Colors.blue, size: 20),
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
            _buildTabItem(0, Icons.feed, 'Posts'),
            const SizedBox(width: 8),
            _buildTabItem(1, Icons.inventory_2_outlined, 'Products (247)'),
            const SizedBox(width: 8),
            _buildTabItem(2, Icons.local_offer_outlined, 'Deals'),
            const SizedBox(width: 8),
            _buildTabItem(3, Icons.star_outline, 'Reviews'),
            const SizedBox(width: 8),
            _buildTabItem(4, Icons.info_outline, 'About'),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, IconData icon, String label) {
    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF5BA00) : Colors.white,
          border: isActive ? null : Border.all(color: const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? const Color(0xFF0F172A) : const Color(0xFF475569)),
            const SizedBox(width: 6),
            Text(
              label, 
              style: TextStyle(
                color: isActive ? const Color(0xFF0F172A) : const Color(0xFF475569), 
                fontSize: 12, 
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPostsTab();
      case 1:
        return _buildProductsTab();
      case 2:
        return _buildDealsTab();
      case 3:
        return _buildReviewsTab();
      case 4:
        return _buildAboutTab();
      default:
        return _buildPostsTab();
    }
  }

  Widget _buildProductsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Products (${dummyWishlist.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: dummyWishlist.length,
            itemBuilder: (context, index) {
              return ProductCardM(product: dummyWishlist[index]);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDealsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Deals & Coupons",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dummyCoupons.length,
            itemBuilder: (context, index) {
              return CouponCard(coupon: dummyCoupons[index]);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Ratings & Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          // Rating Summary Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Left: Rating Score
                Column(
                  children: [
                    const Text("4.8", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1.0)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 14)),
                    ),
                    const SizedBox(height: 4),
                    const Text("128 Verified Ratings", style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(width: 24),
                // Right: Rating Bars
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar("5", 0.88, "88%"),
                      _buildRatingBar("4", 0.08, "8%"),
                      _buildRatingBar("3", 0.03, "3%"),
                      _buildRatingBar("2", 0.01, "1%"),
                      _buildRatingBar("1", 0.00, "0%"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Highlights
          _buildReviewHighlight(Icons.verified, "100% Genuine Products (98%)", Colors.green),
          const SizedBox(height: 8),
          _buildReviewHighlight(Icons.local_shipping, "Fast Delivery (96%)", Colors.orange),
          const SizedBox(height: 16),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildReviewFilter("All Reviews (128)", true),
                const SizedBox(width: 8),
                _buildReviewFilter("With Photos (42)", false),
                const SizedBox(width: 8),
                _buildReviewFilter("5 Stars (112)", false),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reviews List
          _buildReviewCard(
            initials: "TS",
            name: "TechServe Bangladesh Ltd.",
            buyerType: "Verified B2B Buyer",
            timeAgo: "2 days ago",
            productInfo: "Dell Inspiron 15 3520 (Bulk lot x25)",
            reviewText: "Procured 25 laptops for our engineering team onboarding. Warehouse dispatch was completed within 24 hours with full corporate VAT challan and official Dell ProSupport warranty cards intact. Outstanding wholesale pricing.",
            helpfulCount: 16,
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            initials: "VS",
            name: "Vertex System Solutions",
            buyerType: "Trade Assured Buyer",
            timeAgo: "1 week ago",
            productInfo: "Dell UltraSharp 27\" 4K USB-C Hub Monitor (x6)",
            reviewText: "Top quality IPS Black panels with pristine color accuracy. Zero dead pixels across all 6 units. Packaging was reinforced for transport.",
            helpfulCount: 9,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String star, double percent, String percentText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text("$star★", style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey.shade200,
                color: Colors.orange,
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 24,
            child: Text(percentText, style: TextStyle(fontSize: 10, color: Colors.grey.shade600), textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewHighlight(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.shade50,
        border: Border.all(color: color.shade100),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color.shade700)),
        ],
      ),
    );
  }

  Widget _buildReviewFilter(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0F172A) : Colors.white,
        border: isActive ? null : Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildReviewCard({
    required String initials,
    required String name,
    required String buyerType,
    required String timeAgo,
    required String productInfo,
    required String reviewText,
    required int helpfulCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF0F172A),
                radius: 18,
                child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text(buyerType, style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(timeAgo, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(productInfo, style: TextStyle(color: Colors.grey.shade700, fontSize: 10), overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(reviewText, style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF333333))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text("Helpful ($helpfulCount)", style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox.shrink(),
            ],
          ),
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
          const Text("About Company", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Text(
            "${widget.userId} is a leading B2B supplier specializing in high-quality industrial and tech products. "
            "With over 4 years of established presence, we are committed to delivering top-tier service, bulk pricing discounts, "
            "and secure packaging for enterprise clients across Bangladesh. Our operations are headquartered in Tejgaon, Dhaka.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text("Contact Information", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
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
              Text("contact@${widget.userId.replaceAll(' ', '').toLowerCase()}.com", style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
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

  Widget _buildPostsTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildPostCard(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildPostCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDbn-41aH0LtJ739sqcIJsNCjVUDI7Rznebe-23n6uI7hPMbL5bIqz4f5V83Ej3CMyvXJrKvxTeweTg7n-SRvcuIgzTLVf62NMmcyRtlOxn3dnNFJoWpt1_We1Yd6MNRy803zGrZNqeItTDFeyXpPGzs69nphAUl_QrV5Yp6e__9dFvuctaKCuovwoPPJeaoXmPCadCzslX7WIHbVl-P5MUTt2Ap_N3MAunuPGQGtR4IXQhYbJJWkyP8A',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(widget.userId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text('2 hours ago · Tejgaon', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    ],
                  ),
                ),
                const Icon(Icons.more_horiz, color: Color(0xFF94A3B8), size: 18),
              ],
            ),
          ),
          
          // Post Content Text
          const Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Text(
              '🚀 New stock arrived! Premium Dell Inspiron 15 Core i5 13th Gen available in bulk. DM for wholesale rates & guaranteed warranty packages.',
              style: TextStyle(fontSize: 12, color: Color(0xFF1E293B), height: 1.5),
            ),
          ),
          
          // Embedded Rich Product Attachment Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: AspectRatio(
                        aspectRatio: 21 / 9,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF475569).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('In Stock', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                
                // Product Specs and Price
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dell Inspiron 15 3520 (12th Gen Core i5, 8GB RAM, 512GB SSD)',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tejgaon Warehouse · Fast Delivery',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: const [
                              Text('৳45,000', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                              SizedBox(width: 4),
                              Text('/unit', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5BA00),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Inquire Now', style: TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Social Engagement Stats & Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.thumb_up_alt_outlined, size: 16, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text('Interested (12)', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text('Comment (3)', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                Row(
                  children: const [
                    Icon(Icons.share_outlined, size: 16, color: Color(0xFF64748B)),
                    SizedBox(width: 6),
                    Text('Share', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(Icons.home_outlined, 'Home', false),
              _buildBottomNavItem(Icons.inventory_2, 'Products', true),
              _buildBottomNavItem(Icons.chat_bubble_outline, 'Messages', false),
              _buildBottomNavItem(Icons.shopping_cart_outlined, 'Cart', false),
              _buildBottomNavItem(Icons.person_outline, 'Account', false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? const Color(0xFFD97706) : const Color(0xFF94A3B8);
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 28,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFF5BA00).withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
