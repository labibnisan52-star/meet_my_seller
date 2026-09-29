import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meet_my_app_seller/providers/post_provider.dart';
import 'package:meet_my_app_seller/models/product_card_model.dart';
import 'package:meet_my_app_seller/widgets/post/tag_product_bottom_sheet.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _postTextController = TextEditingController();

  final List<XFile> _selectedMedia = [];
  ProductCardModel? _taggedProduct;
  final ImagePicker _picker = ImagePicker();
  
  bool _isPosting = false;

  @override
  void dispose() {
    _postTextController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedMedia.addAll(pickedFiles);
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _selectedMedia.removeAt(index);
    });
  }

  Future<void> _openTagProductBottomSheet() async {
    final ProductCardModel? selected = await showTagProductBottomSheet(context);
    if (selected != null) {
      setState(() {
        _taggedProduct = selected;
      });
    }
  }

  void _removeTaggedProduct() {
    setState(() {
      _taggedProduct = null;
    });
  }

  Future<void> _submitPost() async {
    if (_postTextController.text.trim().isEmpty && _selectedMedia.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add some text or media to post.')),
      );
      return;
    }

    setState(() {
      _isPosting = true;
    });

    // Simulate a network request to make it feel real
    await Future.delayed(const Duration(seconds: 2));

    // Since PostCard uses Image.network, we mock the uploaded image URL
    String? imgUrl;
    if (_selectedMedia.isNotEmpty) {
      imgUrl = 'https://images.unsplash.com/photo-1504328345606-18bbc8c9d7d1?q=80&w=2070&auto=format&fit=crop';
    }

    if (!mounted) return;

    context.read<PostProvider>().addPost(
      userName: "Dell Technologies BD",
      postText: _postTextController.text.trim(),
      imgUrl: imgUrl,
    );
    
    setState(() {
      _isPosting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post successfully published!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
            child: ElevatedButton(
              onPressed: _isPosting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC107),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                      ),
                    )
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with badge
                        Stack(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF101828),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.public, color: Colors.blueAccent, size: 28),
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check_circle, color: Color(0xFF00897B), size: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    "Dell Technologies BD",
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0F2F1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFF80CBC4)),
                                    ),
                                    child: const Text(
                                      "Verified\nHub",
                                      style: TextStyle(color: Color(0xFF00695C), fontSize: 9, fontWeight: FontWeight.bold, height: 1),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.public, size: 14, color: Colors.grey.shade700),
                                    const SizedBox(width: 6),
                                    Text("Public (All Buyers)", style: TextStyle(fontSize: 12, color: Colors.grey.shade800, fontWeight: FontWeight.w600)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey.shade700),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Text Area
                    TextFormField(
                      controller: _postTextController,
                      maxLines: null,
                      style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
                      decoration: const InputDecoration(
                        hintText: "What's on your mind?",
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Media Gallery Section
                    if (_selectedMedia.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            Image.file(
                              File(_selectedMedia.first.path),
                              width: double.infinity,
                              height: 220,
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeMedia(0),
                                child: _buildCloseButton(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 80,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedMedia.length + 1,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            if (index == _selectedMedia.length) {
                              return GestureDetector(
                                onTap: _pickMedia,
                                child: _buildAddMoreThumbnail(),
                              );
                            }
                            return _buildThumbnail(
                              file: File(_selectedMedia[index].path),
                              label: "Photo ${index + 1}",
                              isActive: index == 0,
                              onRemove: () => _removeMedia(index),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Tagged Product Section
                    if (_taggedProduct != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "TAGGED PRODUCT",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          GestureDetector(
                            onTap: _openTagProductBottomSheet,
                            child: Text(
                              "Edit SKU",
                              style: TextStyle(color: Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F8FB),
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _taggedProduct!.imageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 48, height: 48, color: Colors.grey.shade200, child: const Icon(Icons.image, color: Colors.grey)
                                )
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _taggedProduct!.name,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 14, color: Colors.blueGrey.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        "MOQ: ${_taggedProduct!.MOQ.toInt()} units",
                                        style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 13, fontWeight: FontWeight.w600),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Icon(Icons.circle, size: 4, color: Colors.grey),
                                      ),
                                      Text(
                                        "Wholesale\nVerified",
                                        style: TextStyle(color: Color(0xFF00897B), fontSize: 11, fontWeight: FontWeight.bold, height: 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _removeTaggedProduct,
                              child: Icon(Icons.close, size: 20, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Add to your post",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _pickMedia,
                        icon: const Icon(Icons.image_outlined, size: 20),
                        label: const Text("Photo/Video", style: TextStyle(fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openTagProductBottomSheet,
                        icon: const Icon(Icons.sell_outlined, size: 20, color: Color(0xFF00897B)),
                        label: const Text("Tag Product", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildCloseButton() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.close, color: Colors.white, size: 16),
    );
  }

  Widget _buildThumbnail({required File file, String? label, bool isActive = false, required VoidCallback onRemove}) {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        border: isActive ? Border.all(color: const Color(0xFFFFC107), width: 2) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isActive ? 6 : 8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(file, fit: BoxFit.cover),
            if (isActive)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  decoration: const BoxDecoration(color: Color(0xFFFFC107), shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
            if (label != null)
              Positioned(
                bottom: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                  child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            if (!isActive)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: _buildCloseButton(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMoreThumbnail() {
    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDE7),
        border: Border.all(color: const Color(0xFFFFC107), style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, color: Colors.orange.shade700, size: 24),
          const SizedBox(height: 4),
          Text("+ Add More", style: TextStyle(color: Colors.blueGrey.shade800, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
