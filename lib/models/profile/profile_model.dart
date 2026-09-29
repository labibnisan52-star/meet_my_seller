class ProfileModel {
  final String userName;
  final String initials;
  final String customerType;
  final int credits;
  final String activeLevel;
  final String address;
  final bool isOnline;
  final String? profileImageUrl;

  ProfileModel({
    required this.userName,
    required this.initials,
    required this.customerType,
    required this.credits,
    required this.activeLevel,
    required this.address,
    this.isOnline = true, this.profileImageUrl,
  });
}