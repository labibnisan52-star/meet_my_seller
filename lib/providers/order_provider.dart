import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/models/order_model.dart';
import 'package:meet_my_app_seller/data/dummy_data.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderModel> _orders = List.from(dummyOrders);

  List<OrderModel> get orders => _orders;
  
  List<OrderModel> get recentOrders {
    // Return top 5 orders for dashboard
    return _orders.take(5).toList();
  }
}
