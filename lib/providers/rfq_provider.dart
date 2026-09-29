import 'package:flutter/material.dart';
import 'package:meet_my_app_seller/data/dummy_data.dart';
import 'package:meet_my_app_seller/models/rfq_model.dart';

class RFQProvider extends ChangeNotifier {
  // shuru te dummy data diye list load kore rakhlam,
  // pore user notun RFQ post korle eikhane add hobe
  final List<RfqModel> _rfqs = List.from(dummyRfqs);

  List<RfqModel> get rfqs => _rfqs;

  // ── Notun RFQ add kora (Post RFQ form theke call hobe) ──────────────
  void addRfq({
    required String productName,
    required int quantity,
    required double targetPrice,
    required String expiresIn,
  }) {
    final newRfq = RfqModel(
      rfqId: _generateRfqId(),
      productName: productName,
      quantity: quantity,
      targetPrice: targetPrice,
      expiresIn: expiresIn,
      quoteCount: 0,
      status: "Pending", // notun RFQ shurute always Pending thakbe
      bestQuotePrice: null,
      bestQuoteSupplier: null,
      isVerifiedSupplier: false,
    );

    _rfqs.insert(0, newRfq); // notun ta shobar upore dekhabe
    notifyListeners();
  }

  // ── Shimple auto id generator: RFQ-0052, RFQ-0053... ─────────────────
  String _generateRfqId() {
    final nextNumber = _rfqs.length + 52; // dummy data 51 porjonto ache tai 52 theke shuru
    return "RFQ-${nextNumber.toString().padLeft(4, '0')}";
  }

  // ── Submit quote for an existing RFQ (Seller Side) ─────────────────
  void submitQuote(String rfqId, double myQuotePrice, String message) {
    final index = _rfqs.indexWhere((r) => r.rfqId == rfqId);
    if (index != -1) {
      final current = _rfqs[index];
      // Simple logic to determine if this is the best quote
      double newBestQuote = current.bestQuotePrice ?? double.infinity;
      String? newBestSupplier = current.bestQuoteSupplier;
      
      if (myQuotePrice < newBestQuote) {
        newBestQuote = myQuotePrice;
        newBestSupplier = "Me (Seller)";
      }

      final updatedRfq = RfqModel(
        rfqId: current.rfqId,
        productName: current.productName,
        quantity: current.quantity,
        targetPrice: current.targetPrice,
        expiresIn: current.expiresIn,
        quoteCount: current.quoteCount + 1,
        status: "Quoted",
        bestQuotePrice: newBestQuote,
        bestQuoteSupplier: newBestSupplier,
        isVerifiedSupplier: current.isVerifiedSupplier,
        imgUrl: current.imgUrl,
      );

      _rfqs[index] = updatedRfq;
      notifyListeners();
    }
  }
}
