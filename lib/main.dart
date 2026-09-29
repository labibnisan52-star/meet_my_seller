import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/providers/cart_provider.dart';
import 'package:meet_my_app_seller/providers/wishlist_provider.dart';
import 'package:meet_my_app_seller/providers/rfq_provider.dart';
import 'package:meet_my_app_seller/providers/post_provider.dart';
import 'package:meet_my_app_seller/providers/notification_provider.dart';
import 'package:meet_my_app_seller/providers/dashboard_provider.dart';
import 'package:meet_my_app_seller/providers/order_provider.dart';
import 'package:meet_my_app_seller/providers/profile_provider.dart';
import 'package:meet_my_app_seller/providers/category_provider.dart';
import 'package:meet_my_app_seller/screens/seller/seller_main_screen.dart';
import 'package:meet_my_app_seller/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => RFQProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SellerMainScreen(),
    );
  }
}
