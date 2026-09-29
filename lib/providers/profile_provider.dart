import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/data/dummy_data.dart';
import 'package:meet_my_app_seller/models/profile/profile_model.dart';
import 'package:meet_my_app_seller/models/profile/post_model.dart';
import 'package:meet_my_app_seller/models/product_card_model.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  ProfileModel? _currentProfile;
  List<PostModel> _userPosts = [];
  List<ProductCardModel> _userProducts = [];

  bool get isLoading => _isLoading;
  ProfileModel? get currentProfile => _currentProfile;
  List<PostModel> get userPosts => _userPosts;
  List<ProductCardModel> get userProducts => _userProducts;

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    
    // Defer notifyListeners to avoid build phase conflicts if called in initState
    Future.microtask(() => notifyListeners());

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // For demo purposes, we load the dummy data regardless of userId
    _currentProfile = dummyProfile;
    _userPosts = List.from(dummyPosts);
    _userProducts = List.from(dummyWishlist); // using wishlist models as dummy products

    _isLoading = false;
    notifyListeners();
  }
}
