import 'package:flutter/material.dart';

class MockOrder {
  final double orderAmount;
  final double amountPaid;
  final bool isCompleted;
  final double productCostPrice;
  final int quantitySold;

  MockOrder({
    required this.orderAmount,
    required this.amountPaid,
    required this.isCompleted,
    required this.productCostPrice,
    required this.quantitySold,
  });
}

class MockReturn {
  final double refundAmount;
  final int quantityReturned;
  final double productCostPrice;

  MockReturn({
    required this.refundAmount,
    required this.quantityReturned,
    required this.productCostPrice,
  });
}

class MockPurchase {
  final double purchaseAmount;

  MockPurchase({required this.purchaseAmount});
}

class DashboardProvider extends ChangeNotifier {
  String _selectedDateRange = 'Today';
  final List<String> dateRangeOptions = ['Today', 'This Week', 'This Month', 'Custom Range'];

  // --- MOCK DATA ---
  // In a real app, this data would be fetched based on _selectedDateRange.
  // For demonstration, we use fixed lists but the math strictly follows the rules.
  final List<MockOrder> _orders = [
    MockOrder(orderAmount: 20000, amountPaid: 20000, isCompleted: true, productCostPrice: 100, quantitySold: 100),
    MockOrder(orderAmount: 15000, amountPaid: 5000, isCompleted: true, productCostPrice: 100, quantitySold: 75), // Partial payment
    MockOrder(orderAmount: 10000, amountPaid: 0, isCompleted: false, productCostPrice: 50, quantitySold: 100), // Unpaid
  ];

  final List<MockReturn> _returns = [
    MockReturn(refundAmount: 2000, quantityReturned: 10, productCostPrice: 100),
  ];

  final List<MockPurchase> _purchases = [
    MockPurchase(purchaseAmount: 8000),
    MockPurchase(purchaseAmount: 4000),
  ];

  String get selectedDateRange => _selectedDateRange;

  void updateDateRange(String range) {
    if (dateRangeOptions.contains(range)) {
      _selectedDateRange = range;
      notifyListeners();
    }
  }

  // 1. Net Sales = Σ(order_amount for all completed orders) - Σ(refund_amount)
  double get netSales {
    double completedOrdersTotal = _orders
        .where((o) => o.isCompleted)
        .fold(0, (sum, o) => sum + o.orderAmount);
    double refundsTotal = _returns.fold(0, (sum, r) => sum + r.refundAmount);
    return completedOrdersTotal - refundsTotal;
  }

  // 2. COGS = Σ(quantity_sold × product_cost_price)
  double get _cogs {
    // Only count COGS for completed orders to align with recognized sales
    double baseCogs = _orders
        .where((o) => o.isCompleted)
        .fold(0, (sum, o) => sum + (o.quantitySold * o.productCostPrice));
    
    // Critical fix: deduct restocked inventory at cost price, not selling price
    double restockedValue = _returns.fold(0, (sum, r) => sum + (r.quantityReturned * r.productCostPrice));
    
    return baseCogs - restockedValue;
  }

  // 3. Net Purchase = Σ(purchase_amount for all inventory purchased)
  double get netPurchase {
    return _purchases.fold(0, (sum, p) => sum + p.purchaseAmount);
  }

  // 4. Net Profit = Net Sales − COGS − Operating Expenses (Omitted)
  double get netProfit {
    return netSales - _cogs;
  }

  // 5. Outstanding = Σ(order_amount − amount_paid) for all orders with unpaid/partial balance
  double get outstanding {
    return _orders
        .where((o) => o.orderAmount > o.amountPaid)
        .fold(0, (sum, o) => sum + (o.orderAmount - o.amountPaid));
  }
}
