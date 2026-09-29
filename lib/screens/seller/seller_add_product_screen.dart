import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:meet_my_app_seller/services/image_enhancement_service.dart';
import 'package:provider/provider.dart';
import 'package:meet_my_app_seller/providers/category_provider.dart';

const _kGold = AppTheme.primaryGold;
const _kBg = Color(0xFFF5F6FA);
const _kCardBg = Colors.white;
const _kBorder = Color(0xFFE8E8F0);
const _kTextPrimary = Color(0xFF1A1A2E);
const _kTextSecondary = Color(0xFF8888A0);
const _kDanger = Color(0xFFFF4D6A);

// Screen entry point

class SellerAddProductScreen extends StatefulWidget {
  const SellerAddProductScreen({super.key});

  @override
  State<SellerAddProductScreen> createState() => _SellerAddProductScreenState();
}

class _SellerAddProductScreenState extends State<SellerAddProductScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late final PageController _pageController;

  // Step 0 – Basic Info
  final _productNameCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String? _selectedCategory;
  final List<String> _keywords = [];
  final _keywordCtrl = TextEditingController();
  final List<dynamic> _imagePaths = List.filled(10, null);
  final ImagePicker _picker = ImagePicker();
  bool _isEnhanced = false;

  // Step 1 – Pricing
  final _moqCtrl = TextEditingController(text: '10');
  String _unitType = 'Pieces [pcs]';
  final List<Map<String, TextEditingController>> _bulkTiers = [];
  // Sample Order
  bool _enableSamplePrice = true;
  final _samplePriceCtrl = TextEditingController(text: '600');
  bool _sampleAvailable = true;
  String _currency = 'BDT';

  // Step 2 – Variations
  bool _hasVariations = false;
  final List<_VariationGroup> _variationGroups = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Default 3 tiers matching screenshot
    _bulkTiers.addAll([
      {
        'minQty': TextEditingController(text: '1'),
        'maxQty': TextEditingController(text: '99'),
        'price': TextEditingController(text: '500'),
      },
      {
        'minQty': TextEditingController(text: '100'),
        'maxQty': TextEditingController(text: '499'),
        'price': TextEditingController(text: '450'),
      },
      {
        'minQty': TextEditingController(text: '500'),
        'maxQty': TextEditingController(text: '999'),
        'price': TextEditingController(text: '400'),
      },
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _productNameCtrl.dispose();
    _descriptionCtrl.dispose();
    _keywordCtrl.dispose();
    _moqCtrl.dispose();
    _samplePriceCtrl.dispose();
    for (final t in _bulkTiers) {
      t['minQty']!.dispose();
      t['maxQty']!.dispose();
      t['price']!.dispose();
    }
    super.dispose();
  }

  void _goToStep(int step) {
    if (step < 0 || step > 2) return;
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPublish() => _showSuccessSheet();

  void _onSaveDraft() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFFFFFFFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.save_outlined, color: _kGold, size: 18),
            const SizedBox(width: 10),
            Text(
              'Draft saved!',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _PublishSuccessSheet(
        onDone: () {
          Navigator.pop(context); // Close bottom sheet
          
          final newProductData = {
            'name': _productNameCtrl.text.isEmpty ? 'New Product' : _productNameCtrl.text,
            'price': '\$${_bulkTiers.isNotEmpty ? _bulkTiers.first['price']!.text : '0'}',
            'moq': int.tryParse(_moqCtrl.text) ?? 10,
            'imageUrl': _imagePaths[0] is String ? _imagePaths[0] : 'https://via.placeholder.com/500?text=New+Product',
          };
          
          Navigator.pop(context, newProductData); // Return to inventory screen
        },
      ),
    );
  }

  // keyword helpers
  void _addKeyword(String kw) {
    final t = kw.trim();
    if (t.isNotEmpty && !_keywords.contains(t)) {
      setState(() => _keywords.add(t));
    }
    _keywordCtrl.clear();
  }

  void _removeKeyword(String kw) => setState(() => _keywords.remove(kw));

  // image helpers
  Future<void> _handleImageTap(int i) async {
    if (_imagePaths[i] != null) {
      _showImagePreviewDialog(i);
    } else {
      await _pickImageForSlot(i);
    }
  }

  Future<void> _pickImageForSlot(int i) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePaths[i] = image.path;
      });
    }
  }

  void _showImagePreviewDialog(int i) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _getImageWidget(_imagePaths[i]),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
                      onPressed: () {
                        Navigator.pop(context);
                        _pickImageForSlot(i);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
                      onPressed: () {
                        setState(() => _imagePaths[i] = null);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _getImageWidget(dynamic imagePath) {
    if (imagePath is Uint8List) {
      return Image.memory(imagePath, fit: BoxFit.contain);
    } else if (kIsWeb) {
      return Image.network(imagePath as String, fit: BoxFit.contain);
    } else {
      return Image.file(File(imagePath as String), fit: BoxFit.contain);
    }
  }

  // bulk tier helpers
  void _addBulkTier() => setState(
    () => _bulkTiers.add({
      'minQty': TextEditingController(),
      'maxQty': TextEditingController(),
      'price': TextEditingController(),
    }),
  );
  void _removeBulkTier(int i) {
    final t = _bulkTiers.removeAt(i);
    t['minQty']!.dispose();
    t['maxQty']!.dispose();
    t['price']!.dispose();
    setState(() {});
  }

  // variation helpers
  void _addVariationGroup() => setState(
    () => _variationGroups.add(
      _VariationGroup(
        nameCtrl: TextEditingController(),
        options: [TextEditingController()],
      ),
    ),
  );
  void _removeVariationGroup(int i) {
    final g = _variationGroups.removeAt(i);
    g.nameCtrl.dispose();
    for (final o in g.options) {
      o.dispose();
    }
    setState(() {});
  }

  void _addVariationOption(int gi) =>
      setState(() => _variationGroups[gi].options.add(TextEditingController()));
  void _removeVariationOption(int gi, int oi) {
    final c = _variationGroups[gi].options.removeAt(oi);
    c.dispose();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildTopBar(),
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _BasicInfoStep(
                  productNameCtrl: _productNameCtrl,
                  descriptionCtrl: _descriptionCtrl,
                  selectedCategory: _selectedCategory,
                  categories: context.watch<CategoryProvider>().categories,
                  keywords: _keywords,
                  keywordCtrl: _keywordCtrl,
                  imagePaths: _imagePaths,
                  isEnhanced: _isEnhanced,
                  onEnhanceStyleSelected: (style) async {
                    if (_imagePaths[0] == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please add a product image first.')),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                        child: CircularProgressIndicator(color: _kGold),
                      ),
                    );
                    try {
                      final service = ImageEnhancementService();
                      final newPath = await service.enhanceImage(_imagePaths[0]!, style);
                      setState(() {
                        _imagePaths[0] = newPath;
                        _isEnhanced = true;
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to enhance image: $e')),
                      );
                    } finally {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  onCategoryChanged: (v) =>
                      setState(() => _selectedCategory = v),
                  onAddKeyword: _addKeyword,
                  onRemoveKeyword: _removeKeyword,
                  onImageTap: _handleImageTap,
                ),
                _PricingStep(
                  moqCtrl: _moqCtrl,
                  unitType: _unitType,
                  bulkTiers: _bulkTiers,
                  enableSamplePrice: _enableSamplePrice,
                  samplePriceCtrl: _samplePriceCtrl,
                  sampleAvailable: _sampleAvailable,
                  currency: _currency,
                  onUnitTypeChanged: (v) => setState(() => _unitType = v),
                  onAddTier: _addBulkTier,
                  onRemoveTier: _removeBulkTier,
                  onToggleSamplePrice: (v) =>
                      setState(() => _enableSamplePrice = v),
                  onToggleSampleAvailable: (v) =>
                      setState(() => _sampleAvailable = v),
                  onCurrencyChanged: (v) => setState(() => _currency = v),
                ),
                _VariationsStep(
                  hasVariations: _hasVariations,
                  variationGroups: _variationGroups,
                  onToggle: (v) => setState(() => _hasVariations = v),
                  onAddGroup: _addVariationGroup,
                  onRemoveGroup: _removeVariationGroup,
                  onAddOption: _addVariationOption,
                  onRemoveOption: _removeVariationOption,
                ),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 8,
        right: 16,
        bottom: 12,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: _kTextPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Post a Product',
              style: GoogleFonts.inter(
                color: _kTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: _onSaveDraft,
            child: Text(
              'Save as Draft',
              style: GoogleFonts.inter(
                color: _kGold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Basic Info', 'Pricing', 'Variations'];
    return Container(
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: GestureDetector(
              onTap: () => _goToStep(i),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDone || isActive)
                                ? _kGold
                                : const Color(0xFFE8E8F0),
                            border: Border.all(
                              color: (isActive || isDone)
                                  ? _kGold
                                  : const Color(0xFFD0D0E0),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.black,
                                    size: 16,
                                  )
                                : Text(
                                    '${i + 1}',
                                    style: GoogleFonts.inter(
                                      color: isActive
                                          ? Colors.black
                                          : _kTextSecondary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          steps[i],
                          style: GoogleFonts.inter(
                            color: isActive
                                ? _kGold
                                : isDone
                                ? _kGold.withOpacity(0.70)
                                : _kTextSecondary,
                            fontSize: 10,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 1.5,
                        margin: const EdgeInsets.only(bottom: 18),
                        color: i < _currentStep
                            ? _kGold.withOpacity(0.60)
                            : const Color(0xFFE8E8F0),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isFirst = _currentStep == 0;
    final isLast = _currentStep == 2;
    const nextLabels = [
      'Next: Pricing',
      'Next: Variations',
      'Publish',
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE8E8F0))),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      child: Row(
        children: [
          if (!isFirst)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _goToStep(_currentStep - 1),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text(
                  'Back',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _kTextSecondary,
                  side: const BorderSide(color: _kBorder),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          if (!isFirst) const SizedBox(width: 12),
          Expanded(
            flex: isFirst ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: isLast
                  ? _onPublish
                  : () => _goToStep(_currentStep + 1),
              icon: Icon(
                isLast
                    ? Icons.rocket_launch_rounded
                    : Icons.arrow_forward_rounded,
                size: 16,
              ),
              label: Text(
                nextLabels[_currentStep],
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper data class
// ─────────────────────────────────────────────────────────────────────────────
class _VariationGroup {
  final TextEditingController nameCtrl;
  final List<TextEditingController> options;
  _VariationGroup({required this.nameCtrl, required this.options});
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 0 – Basic Info
// ─────────────────────────────────────────────────────────────────────────────
class _BasicInfoStep extends StatelessWidget {
  final TextEditingController productNameCtrl;
  final TextEditingController descriptionCtrl;
  final String? selectedCategory;
  final List<String> categories;
  final List<String> keywords;
  final TextEditingController keywordCtrl;
  final List<dynamic> imagePaths;
  final bool isEnhanced;
  final ValueChanged<String> onEnhanceStyleSelected;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onAddKeyword;
  final ValueChanged<String> onRemoveKeyword;
  final ValueChanged<int> onImageTap;

  const _BasicInfoStep({
    required this.productNameCtrl,
    required this.descriptionCtrl,
    required this.selectedCategory,
    required this.categories,
    required this.keywords,
    required this.keywordCtrl,
    required this.imagePaths,
    required this.isEnhanced,
    required this.onEnhanceStyleSelected,
    required this.onCategoryChanged,
    required this.onAddKeyword,
    required this.onRemoveKeyword,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          icon: Icons.image_outlined,
          title: 'Product Images',
          subtitle: 'Add up to 10 images. ',
          subtitleSpan: 'High-quality images increase conversion.',
          child: _buildImageGrid(context),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.info_outline_rounded,
          title: 'Basic Information',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(label: 'Product Name', required: true),
              _StyledTextField(
                controller: productNameCtrl,
                hint: 'e.g. Industrial Strength Packaging Tape',
              ),
              const SizedBox(height: 16),
              const _FieldLabel(label: 'Category', required: true),
              _StyledDropdown(
                hint: 'Select a category',
                value: selectedCategory,
                items: categories,
                onChanged: onCategoryChanged,
              ),
              const SizedBox(height: 16),
              const _FieldLabel(label: 'Product Description'),
              _StyledTextField(
                controller: descriptionCtrl,
                hint:
                    'Describe the key features, materials, and applications...',
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              const _FieldLabel(label: 'Keywords'),
              _KeywordsField(
                keywords: keywords,
                controller: keywordCtrl,
                onAdd: onAddKeyword,
                onRemove: onRemoveKeyword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildImageGrid(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemCount: 5,
          itemBuilder: (_, i) => _ImageSlot(
            index: i,
            isCover: i == 0,
            imagePath: imagePaths[i],
            isEnhanced: isEnhanced,
            onTap: () => onImageTap(i),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E), // POS-style flat dark background
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF3A3A3C), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEnhanceSheet(context),
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ), // Chunky touch target
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFFFD60A), // High contrast yellow
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ENHANCE PHOTOS',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w800, // Bold POS typography
                        fontSize: 16,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEnhanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: Color(0xFF7C4DFF),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'AI Enhancement Options',
                  style: GoogleFonts.inter(
                    color: _kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Select a style to make your product photos stand out using Gemini Nano.',
              style: GoogleFonts.inter(color: _kTextSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            _EnhanceOptionCard(
              icon: Icons.work_outline_rounded,
              title: 'Professional',
              subtitle: 'Clean background, studio lighting, crisp details',
              onTap: () {
                Navigator.pop(context);
                onEnhanceStyleSelected('Professional');
              },
            ),
            const SizedBox(height: 12),
            _EnhanceOptionCard(
              icon: Icons.color_lens_outlined,
              title: 'Vibrant',
              subtitle: 'Enhanced colors, high contrast, popping details',
              onTap: () {
                Navigator.pop(context);
                onEnhanceStyleSelected('Vibrant');
              },
            ),
            const SizedBox(height: 12),
            _EnhanceOptionCard(
              icon: Icons.movie_filter_outlined,
              title: 'Creative',
              subtitle: 'Artistic angles, dramatic shadows, lifestyle feel',
              onTap: () {
                Navigator.pop(context);
                onEnhanceStyleSelected('Creative');
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGold,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 – Pricing
// ─────────────────────────────────────────────────────────────────────────────
class _PricingStep extends StatelessWidget {
  final TextEditingController moqCtrl;
  final String unitType;
  final List<Map<String, TextEditingController>> bulkTiers;
  final bool enableSamplePrice;
  final TextEditingController samplePriceCtrl;
  final bool sampleAvailable;
  final String currency;
  final ValueChanged<String> onUnitTypeChanged;
  final VoidCallback onAddTier;
  final ValueChanged<int> onRemoveTier;
  final ValueChanged<bool> onToggleSamplePrice;
  final ValueChanged<bool> onToggleSampleAvailable;
  final ValueChanged<String> onCurrencyChanged;

  static const _unitOptions = [
    'Pieces [pcs]',
    'Kilograms [kg]',
    'Grams [g]',
    'Litres [L]',
    'Metres [m]',
    'Boxes [box]',
    'Dozens [doz]',
    'Sets [set]',
  ];
  static const _currencies = ['BDT', 'USD', 'EUR', 'GBP'];

  const _PricingStep({
    required this.moqCtrl,
    required this.unitType,
    required this.bulkTiers,
    required this.enableSamplePrice,
    required this.samplePriceCtrl,
    required this.sampleAvailable,
    required this.currency,
    required this.onUnitTypeChanged,
    required this.onAddTier,
    required this.onRemoveTier,
    required this.onToggleSamplePrice,
    required this.onToggleSampleAvailable,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          icon: Icons.attach_money_rounded,
          title: 'Pricing Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(label: 'Minimum Order Quantity (MOQ)'),
              _StyledTextField(
                controller: moqCtrl,
                hint: '10',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              const _FieldLabel(label: 'Unit'),
              _DarkDropdown(
                value: unitType,
                items: _unitOptions,
                onChanged: (v) {
                  if (v != null) onUnitTypeChanged(v);
                },
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.diamond_outlined, color: _kGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Bulk Pricing Tiers',
                    style: GoogleFonts.inter(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Set different prices based on order quantity',
                style: GoogleFonts.inter(color: _kTextSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ...List.generate(
                bulkTiers.length,
                (i) => _BulkTierRow(
                  tier: bulkTiers[i],
                  index: i,
                  isLast: i == bulkTiers.length - 1,
                  onRemove: () => onRemoveTier(i),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onAddTier,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                    color: _kGold.withValues(alpha: 0.05),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_rounded, color: _kGold, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Add Price Tier',
                        style: GoogleFonts.inter(
                          color: _kGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Sample Order',
                    style: GoogleFonts.inter(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Enable',
                    style: GoogleFonts.inter(
                      color: _kTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Switch(
                    value: enableSamplePrice,
                    onChanged: onToggleSamplePrice,
                    activeThumbColor: _kGold,
                  ),
                ],
              ),
              if (enableSamplePrice) ...[
                const SizedBox(height: 12),
                const _FieldLabel(label: 'Sample Price (Per Unit)'),
                _StyledTextField(
                  controller: samplePriceCtrl,
                  hint: '600',
                  keyboardType: TextInputType.number,
                  prefixText: '৳ ',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Sample Available',
                        style: GoogleFonts.inter(
                          color: _kTextPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: sampleAvailable,
                        onChanged: onToggleSampleAvailable,
                        activeThumbColor: _kGold,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const _FieldLabel(label: 'Currency'),
              _DarkDropdown(
                value: currency,
                items: _currencies,
                onChanged: (v) {
                  if (v != null) onCurrencyChanged(v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _DarkDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DarkDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: _kCardBg,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _kTextSecondary,
            size: 20,
          ),
          style: GoogleFonts.inter(color: _kTextPrimary, fontSize: 14),
          onChanged: onChanged,
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
        ),
      ),
    );
  }
}

class _BulkTierRow extends StatelessWidget {
  final Map<String, TextEditingController> tier;
  final int index;
  final bool isLast;
  final VoidCallback onRemove;
  const _BulkTierRow({
    required this.tier,
    required this.index,
    required this.isLast,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _kGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kGold.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TierTextField(controller: tier['minQty']!, hint: 'Min'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'to',
              style: GoogleFonts.inter(color: _kTextSecondary, fontSize: 13),
            ),
          ),
          Expanded(
            child: _TierTextField(
              controller: tier['maxQty']!,
              hint: isLast ? '999+' : 'Max',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _TierTextField(
              controller: tier['price']!,
              hint: 'Price',
              prefixText: '৳ ',
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.remove_circle_outline_rounded,
              color: _kDanger.withValues(alpha: 0.70),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? prefixText;
  const _TierTextField({
    required this.controller,
    required this.hint,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          if (prefixText != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                prefixText!,
                style: GoogleFonts.inter(
                  color: _kTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(color: _kTextPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  color: _kTextSecondary.withValues(alpha: 0.50),
                  fontSize: 12,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: prefixText == null ? 10 : 4,
                  vertical: 10,
                ),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 – Variations
// ─────────────────────────────────────────────────────────────────────────────
class _VariationsStep extends StatelessWidget {
  final bool hasVariations;
  final List<dynamic> variationGroups;
  final ValueChanged<bool> onToggle;
  final VoidCallback onAddGroup;
  final ValueChanged<int> onRemoveGroup;
  final ValueChanged<int> onAddOption;
  final void Function(int, int) onRemoveOption;

  const _VariationsStep({
    required this.hasVariations,
    required this.variationGroups,
    required this.onToggle,
    required this.onAddGroup,
    required this.onRemoveGroup,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          icon: Icons.layers_rounded,
          title: 'Product Variations',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Does this product have variations?',
                    style: GoogleFonts.inter(
                      color: _kTextPrimary,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: hasVariations,
                    onChanged: onToggle,
                    activeThumbColor: _kGold,
                  ),
                ],
              ),
              if (hasVariations) ...[
                const SizedBox(height: 20),
                const Divider(color: _kBorder, height: 1),
                const SizedBox(height: 20),

                // Color Options
                Row(
                  children: [
                    const Icon(
                      Icons.color_lens_outlined,
                      color: _kGold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Color Options',
                      style: GoogleFonts.inter(
                        color: _kTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _ColorCircle(color: Colors.red, label: 'Red'),
                    _ColorCircle(color: Colors.blue, label: 'Blue'),
                    _ColorCircle(color: Colors.black, label: 'Black'),
                    _ColorCircle(color: Colors.yellow, label: 'Yellow'),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _kGold.withValues(alpha: 0.5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Icon(Icons.add, color: _kGold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Size Options
                Row(
                  children: [
                    const Icon(
                      Icons.straighten_rounded,
                      color: _kGold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Size Options',
                      style: GoogleFonts.inter(
                        color: _kTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SizeChip(label: 'S'),
                    _SizeChip(label: 'M'),
                    _SizeChip(label: 'L'),
                    _SizeChip(label: 'XL'),
                    _SizeChip(label: 'Custom'),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _kGold.withValues(alpha: 0.5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: _kGold, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Add Size',
                            style: GoogleFonts.inter(
                              color: _kGold,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: _kBorder, height: 1),
                const SizedBox(height: 20),

                // Stock & Price per Variation
                Text(
                  'Stock & Price per Variation',
                  style: GoogleFonts.inter(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '8 combinations generated from 4 colors × 2 sizes',
                  style: GoogleFonts.inter(
                    color: _kTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                _VariationComboCard(title: 'Red - S'),
                _VariationComboCard(title: 'Red - M'),
                _VariationComboCard(title: 'Blue - S'),

                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'View all combinations',
                    style: GoogleFonts.inter(
                      color: _kGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: _kGold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const _FieldLabel(label: 'Default Variation'),
                _DarkDropdown(
                  value: 'Red - M',
                  items: const ['Red - S', 'Red - M', 'Blue - S'],
                  onChanged: (v) {},
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final String label;
  const _ColorCircle({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: _kBorder, width: 2),
              ),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: _kCardBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: _kTextSecondary,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(color: _kTextSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  const _SizeChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: _kTextPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.close, color: _kTextSecondary, size: 14),
        ],
      ),
    );
  }
}

class _VariationComboCard extends StatelessWidget {
  final String title;
  const _VariationComboCard({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                'Active',
                style: GoogleFonts.inter(color: _kTextSecondary, fontSize: 12),
              ),
              const SizedBox(width: 4),
              Switch(value: true, onChanged: (v) {}, activeThumbColor: _kGold),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stock',
                      style: GoogleFonts.inter(
                        color: _kTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StyledTextField(
                      controller: TextEditingController(text: '50'),
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: GoogleFonts.inter(
                        color: _kTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StyledTextField(
                      controller: TextEditingController(text: '450'),
                      hint: '0',
                      prefixText: '৳ ',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 – Shipping
// ─────────────────────────────────────────────────────────────────────────────
// ignore: unused_element
class _ShippingStep extends StatelessWidget {
  final TextEditingController supplyAbilityCtrl;
  final String supplyAbilityUnit;
  final TextEditingController leadTimeCtrl;
  final String leadTimeUnit;
  final ValueChanged<String> onSupplyUnitChanged;
  final ValueChanged<String> onLeadTimeUnitChanged;

  const _ShippingStep({
    required this.supplyAbilityCtrl,
    required this.supplyAbilityUnit,
    required this.leadTimeCtrl,
    required this.leadTimeUnit,
    required this.onSupplyUnitChanged,
    required this.onLeadTimeUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SectionCard(
          icon: Icons.inventory_2_outlined,
          title: 'Supply Details',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(label: 'Supply Ability'),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _StyledTextField(
                      controller: supplyAbilityCtrl,
                      hint: '10000',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _DarkDropdown(
                      value: supplyAbilityUnit,
                      items: const ['pcs / Month', 'pcs / Week', 'kg / Month'],
                      onChanged: (v) {
                        if (v != null) onSupplyUnitChanged(v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const _FieldLabel(label: 'Lead Time (Estimated)'),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _StyledTextField(
                      controller: leadTimeCtrl,
                      hint: '14',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: _DarkDropdown(
                      value: leadTimeUnit,
                      items: const ['Days', 'Weeks', 'Months'],
                      onChanged: (v) {
                        if (v != null) onLeadTimeUnitChanged(v);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.warehouse_outlined, color: _kGold, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Stock Status',
                    style: GoogleFonts.inter(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _kGold.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _kGold.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'In Stock',
                        style: GoogleFonts.inter(
                          color: _kGold,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _kCardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBorder),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Made to Order',
                        style: GoogleFonts.inter(
                          color: _kTextSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionCard(
          icon: Icons.local_shipping_outlined,
          title: 'Shipping & Packaging',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FieldLabel(label: 'Package Weight (kg)'),
              _StyledTextField(
                controller: TextEditingController(text: '1.5'),
                hint: 'e.g. 1.5',
                keyboardType: TextInputType.number,
                suffixText: 'kg',
              ),
              const SizedBox(height: 16),
              const _FieldLabel(label: 'Dimensions (cm)'),
              Row(
                children: [
                  Expanded(
                    child: _StyledTextField(
                      controller: TextEditingController(text: '30'),
                      hint: 'L',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StyledTextField(
                      controller: TextEditingController(text: '20'),
                      hint: 'W',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StyledTextField(
                      controller: TextEditingController(text: '15'),
                      hint: 'H',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _kGold.withValues(alpha: 0.12),
                const Color(0xFF7C4DFF).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kGold.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.rocket_launch_rounded, color: _kGold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Almost there!',
                      style: GoogleFonts.inter(
                        color: _kTextPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Tap Publish to list your product live on MeetMy.',
                      style: GoogleFonts.inter(
                        color: _kTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? subtitleSpan;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleSpan,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _kGold,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, color: _kGold, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(color: _kTextSecondary, fontSize: 12),
                children: [
                  TextSpan(text: subtitle),
                  if (subtitleSpan != null)
                    TextSpan(
                      text: subtitleSpan,
                      style: GoogleFonts.inter(color: _kGold, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.inter(
            color: _kGold,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          children: [
            TextSpan(text: label),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: _kDanger),
              ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefixText;
  final String? suffixText;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixText,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(color: _kTextPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          color: _kTextSecondary.withOpacity(0.55),
          fontSize: 14,
        ),
        prefixText: prefixText,
        prefixStyle: GoogleFonts.inter(
          color: _kGold,
          fontWeight: FontWeight.w600,
        ),
        suffixText: suffixText,
        suffixStyle: GoogleFonts.inter(color: _kTextSecondary, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _kGold, width: 1.5),
        ),
      ),
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _StyledDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.inter(
              color: _kTextSecondary.withOpacity(0.55),
              fontSize: 14,
            ),
          ),
          dropdownColor: const Color(0xFFFFFFFF),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _kTextSecondary,
          ),
          isExpanded: true,
          style: GoogleFonts.inter(color: _kTextPrimary, fontSize: 14),
          onChanged: onChanged,
          items: items
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
        ),
      ),
    );
  }
}

class _KeywordsField extends StatelessWidget {
  final List<String> keywords;
  final TextEditingController controller;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> onRemove;

  const _KeywordsField({
    required this.keywords,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...keywords.map(
            (kw) => _Chip(label: kw, onRemove: () => onRemove(kw)),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(color: _kTextPrimary, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Add keyword...',
                hintStyle: GoogleFonts.inter(
                  color: _kTextSecondary.withOpacity(0.50),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: onAdd,
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _Chip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _kGold.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kGold.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: _kGold,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, color: _kGold, size: 14),
          ),
        ],
      ),
    );
  }
}

class _ImageSlot extends StatelessWidget {
  final int index;
  final bool isCover;
  final dynamic imagePath;
  final bool isEnhanced;
  final VoidCallback onTap;
  const _ImageSlot({
    required this.index,
    required this.isCover,
    required this.imagePath,
    this.isEnhanced = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFilled = imagePath != null;
    
    ImageProvider? getImageProvider() {
      if (!isFilled) return null;
      if (imagePath is Uint8List) return MemoryImage(imagePath as Uint8List);
      if (kIsWeb) return NetworkImage(imagePath as String);
      return FileImage(File(imagePath as String));
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isFilled ? _kGold.withOpacity(0.08) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFilled ? _kGold.withOpacity(0.45) : _kBorder,
          width: isFilled ? 1.5 : 1,
        ),
        image: isFilled
            ? DecorationImage(
                image: getImageProvider()!,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: isFilled
          ? Stack(
              alignment: Alignment.center,
              children: [
                if (isCover)
                  Positioned(
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _kGold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Cover',
                        style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: _kGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 12,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isCover) ...[
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    color: _kTextSecondary.withOpacity(0.55),
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Cover Image',
                    style: GoogleFonts.inter(
                      color: _kTextSecondary.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ] else
                  Icon(
                    Icons.add_rounded,
                    color: _kTextSecondary.withOpacity(0.40),
                    size: 28,
                  ),
              ],
            ),
    );

    if (isEnhanced && isFilled) {
      content = Stack(
        children: [
          ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              1.2,
              0,
              0,
              0,
              10,
              0,
              1.2,
              0,
              0,
              10,
              0,
              0,
              1.2,
              0,
              10,
              0,
              0,
              0,
              1,
              0,
            ]),
            child: content,
          ),
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 10),
                  const SizedBox(width: 4),
                  Text(
                    'AI Enhanced',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}

// ignore: unused_element
class _VariationGroupCard extends StatelessWidget {
  final _VariationGroup group;
  final int groupIndex;
  final VoidCallback onRemoveGroup;
  final VoidCallback onAddOption;
  final ValueChanged<int> onRemoveOption;

  const _VariationGroupCard({
    required this.group,
    required this.groupIndex,
    required this.onRemoveGroup,
    required this.onAddOption,
    required this.onRemoveOption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF7C4DFF).withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: group.nameCtrl,
                  style: GoogleFonts.inter(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g. Size, Color',
                    hintStyle: GoogleFonts.inter(
                      color: _kTextSecondary.withOpacity(0.50),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFFFFF),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF7C4DFF)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemoveGroup,
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: _kDanger.withOpacity(0.70),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...List.generate(
                group.options.length,
                (oi) => _OptionChip(
                  ctrl: group.options[oi],
                  onRemove: () => onRemoveOption(oi),
                ),
              ),
              GestureDetector(
                onTap: onAddOption,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF7C4DFF).withOpacity(0.40),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF7C4DFF),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Add',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF7C4DFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionChip extends StatelessWidget {
  final TextEditingController ctrl;
  final VoidCallback onRemove;
  const _OptionChip({required this.ctrl, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF7C4DFF).withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              controller: ctrl,
              style: GoogleFonts.inter(color: _kTextPrimary, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Option',
                hintStyle: GoogleFonts.inter(
                  color: _kTextSecondary.withOpacity(0.40),
                  fontSize: 12,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF7C4DFF),
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Publish Success Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _PublishSuccessSheet extends StatefulWidget {
  final VoidCallback onDone;
  const _PublishSuccessSheet({required this.onDone});

  @override
  State<_PublishSuccessSheet> createState() => _PublishSuccessSheetState();
}

class _PublishSuccessSheetState extends State<_PublishSuccessSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 28),
          ScaleTransition(
            scale: _scale,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [_kGold, Color(0xFFDAA520)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _kGold.withOpacity(0.40),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.rocket_launch_rounded,
                color: Colors.black,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Product Published! 🎉',
            style: GoogleFonts.inter(
              color: _kTextPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your product is now live on MeetMy.\nBuyers can discover and inquire about it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: _kTextSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: widget.onDone,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kGold,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Back to Inventory',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: widget.onDone,
            child: Text(
              'Add Another Product',
              style: GoogleFonts.inter(
                color: _kGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnhanceOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _EnhanceOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF7C4DFF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF7C4DFF), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: _kTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _kTextSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
