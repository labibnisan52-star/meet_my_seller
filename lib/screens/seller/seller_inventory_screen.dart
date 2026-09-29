import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meet_my_app_seller/screens/seller/seller_add_product_screen.dart';
import 'package:meet_my_app_seller/screens/product_detail_screen.dart';
import 'package:meet_my_app_seller/models/product_card_model.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/providers/category_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
enum ProductStatus { inStock, lowStock, outOfStock, draft }

class SellerProduct {
  final String id;
  final String name;
  final String category;
  final String company;
  final String imageUrl;
  final String price;
  final String? strikethroughPrice;
  final int moq;
  final int stock;
  final ProductStatus status;

  SellerProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.company,
    required this.imageUrl,
    required this.price,
    this.strikethroughPrice,
    required this.moq,
    required this.stock,
    required this.status,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class SellerInventoryScreen extends StatefulWidget {
  const SellerInventoryScreen({super.key});

  @override
  State<SellerInventoryScreen> createState() => _SellerInventoryScreenState();
}

class _SellerInventoryScreenState extends State<SellerInventoryScreen> {
  int _selectedFilter = 0; // 0=All, 1=In Stock, 2=Low Stock, 3=Out of Stock
  final List<String> _filters = ['All', 'In Stock', 'Low Stock', 'Out of Stock'];
  String? _selectedCategory;

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
        SellerProduct(
          id: 'mock_1',
          name: 'Dell XPS 13 Plus',
          category: 'Electronics',
          company: companyName,
          imageUrl: 'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          price: '৳185,000',
          strikethroughPrice: '৳200,000',
          moq: 1,
          stock: 24,
          status: ProductStatus.inStock,
        ),
        SellerProduct(
          id: 'mock_2',
          name: 'iPhone 15 Pro Max - 256GB',
          category: 'Mobile Phones',
          company: companyName,
          imageUrl: 'https://images.unsplash.com/photo-1696446701796-da61225697cc?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          price: '৳155,000',
          moq: 5,
          stock: 45,
          status: ProductStatus.inStock,
        ),
        SellerProduct(
          id: 'mock_3',
          name: 'Premium Cotton T-Shirts (Bulk)',
          category: 'Clothing',
          company: companyName,
          imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          price: '৳350',
          strikethroughPrice: '৳500',
          moq: 100,
          stock: 500,
          status: ProductStatus.inStock,
        ),
        SellerProduct(
          id: 'mock_4',
          name: 'Modern Ceramic Vases',
          category: 'Home & Garden',
          company: companyName,
          imageUrl: 'https://images.unsplash.com/photo-1613923769970-13d809a7b54a?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          price: '৳1,200',
          moq: 20,
          stock: 8,
          status: ProductStatus.lowStock,
        ),
        SellerProduct(
          id: 'mock_5',
          name: 'Samsung Galaxy S24 Ultra',
          category: 'Mobile Phones',
          company: companyName,
          imageUrl: 'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?ixlib=rb-4.0.3&auto=format&fit=crop&w=800&q=80',
          price: '৳145,000',
          moq: 2,
          stock: 0,
          status: ProductStatus.outOfStock,
        ),
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

  List<SellerProduct> get _filteredProducts {
    var list = _products;
    if (_selectedFilter == 1) {
      list = list.where((p) => p.status == ProductStatus.inStock).toList();
    } else if (_selectedFilter == 2) {
      list = list.where((p) => p.status == ProductStatus.lowStock).toList();
    } else if (_selectedFilter == 3) {
      list = list.where((p) => p.status == ProductStatus.outOfStock).toList();
    }

    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final Color kBg = const Color(0xFFF5F6FA);
    
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(),
            const SizedBox(height: 12),
            _buildCategorySelector(context),
            const SizedBox(height: 12),
            _buildFilterRow(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Inventory',
            style: GoogleFonts.inter(
              color: const Color(0xFF1A1A2E),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellerAddProductScreen()),
              );
              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  _products.insert(0, SellerProduct(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: result['name'],
                    category: result['category'] ?? 'Electronics',
                    company: 'My Store',
                    imageUrl: result['imageUrl'],
                    price: result['price'],
                    moq: result['moq'],
                    stock: 150,
                    status: ProductStatus.inStock,
                  ));
                });
              }
            },
            icon: const Icon(Icons.add, size: 18),
            label: Text(
              'Add Product',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: const Color(0xFF1A1A2E),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, catProvider, child) {
        final categories = catProvider.categories;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'Categories',
                style: GoogleFonts.inter(
                  color: const Color(0xFF1A1A2E),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildCategoryPill('All'),
                  ...categories.map((c) => _buildCategoryPill(c)),
                  _buildAddCategoryPill(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCategoryPill(String category) {
    final isSelected = (category == 'All' && _selectedCategory == null) || (category == _selectedCategory);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category == 'All' ? null : category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGold : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppTheme.primaryGold : const Color(0xFFE8E8F0),
            ),
          ),
          child: Text(
            category,
            style: GoogleFonts.inter(
              color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFF6B7280),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddCategoryPill(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _showAddCategoryDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryGold.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryGold),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 14, color: AppTheme.primaryGold),
              const SizedBox(width: 4),
              Text(
                'Add',
                style: GoogleFonts.inter(
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final ctrl = TextEditingController();
    String? error;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    decoration: InputDecoration(
                      hintText: 'Category Name',
                      errorText: error,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    final err = context.read<CategoryProvider>().addCategory(ctrl.text);
                    if (err != null) {
                      setStateDialog(() => error = err);
                    } else {
                      setState(() => _selectedCategory = ctrl.text.trim());
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save', style: TextStyle(color: AppTheme.primaryGold)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(_filters.length, (i) {
          final bool isSelected = i == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryGold : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryGold : const Color(0xFFE8E8F0),
                  ),
                ),
                child: Text(
                  _filters[i],
                  style: GoogleFonts.inter(
                    color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFF6B7280),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGrid() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchProducts,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold),
              child: const Text('Retry', style: TextStyle(color: Color(0xFF1A1A2E))),
            ),
          ],
        ),
      );
    }
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Text(
          'No products found.',
          style: GoogleFonts.inter(color: const Color(0xFF6B7280)),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.46, // Adjusted to fit the content perfectly when text wraps
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        return _ProductGridCard(product: _filteredProducts[index]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product Grid Card
// ─────────────────────────────────────────────────────────────────────────────
class _ProductGridCard extends StatelessWidget {
  final SellerProduct product;
  const _ProductGridCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final currentPrice = double.tryParse(product.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
        final originalPrice = double.tryParse((product.strikethroughPrice ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ?? currentPrice;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: ProductCardModel(
                company: product.company,
                name: product.name,
                currentPrice: currentPrice,
                originalPrice: originalPrice,
                MOQ: product.moq.toDouble(),
                imageUrl: product.imageUrl,
                discountPercent: 0,
                specs: {},
              ),
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8F0)),
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
          // Image and badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: kIsWeb || product.imageUrl.startsWith('http') || product.imageUrl.startsWith('blob:')
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                        )
                      : Image.file(
                          File(product.imageUrl),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                        ),
                ),
              ),
              // Status Badge
              Positioned(
                top: 10,
                left: 10,
                child: _buildStatusBadge(),
              ),
              // More options
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert_rounded,
                    size: 16,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
            ],
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.company,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6B7280),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category,
                            style: GoogleFonts.inter(
                              color: AppTheme.secondaryGold,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1A1A2E),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Starting from',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          product.price,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF1A1A2E),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.strikethroughPrice != null) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            product.strikethroughPrice!,
                            style: GoogleFonts.inter(
                              color: const Color(0xFF9CA3AF),
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'MOQ: ${product.moq} Pieces',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  const Divider(height: 1, color: Color(0xFFE8E8F0)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Stock: ${product.stock} units',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF4B5563),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFB8860B),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bg;
    Color fg;
    String label;

    switch (product.status) {
      case ProductStatus.inStock:
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        label = 'IN STOCK';
        break;
      case ProductStatus.lowStock:
        bg = Colors.orange.shade100;
        fg = Colors.orange.shade900;
        label = 'LOW STOCK';
        break;
      case ProductStatus.outOfStock:
        bg = Colors.red.shade100;
        fg = Colors.red.shade800;
        label = 'OUT OF STOCK';
        break;
      case ProductStatus.draft:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade700;
        label = 'DRAFT';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
