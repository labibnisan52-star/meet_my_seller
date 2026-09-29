class BuyerProfileModel {
  final String id;
  final String userName;
  final String initials;
  final String customerType;
  final int credits; // could be double if needed, let's assume int
  final String activeLevel;
  final String address;
  final bool isOnline;
  final String? profileImageUrl;

  BuyerProfileModel({
    required this.id,
    required this.userName,
    required this.initials,
    required this.customerType,
    required this.credits,
    required this.activeLevel,
    required this.address,
    required this.isOnline,
    this.profileImageUrl,
  });

  factory BuyerProfileModel.fromJson(Map<String, dynamic> json) {
    return BuyerProfileModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? json['user_name'] as String? ?? '',
      initials: json['initials'] as String? ?? '',
      customerType: json['customerType'] as String? ?? json['customer_type'] as String? ?? '',
      credits: (json['credits'] as num?)?.toInt() ?? 0,
      activeLevel: json['activeLevel'] as String? ?? json['active_level'] as String? ?? '',
      address: json['address'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? json['is_online'] as bool? ?? false,
      profileImageUrl: json['profileImageUrl'] as String? ?? json['profile_image_url'] as String?,
    );
  }
}
