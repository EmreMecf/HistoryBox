// lib/shared/services/print_order_service.dart
//
// 📖 Fiziksel kitap baskı siparişi (Firestore'a kaydedilir; baskı/kargo
// entegrasyonu — Gelato/Lulu vb. — sonraki adım).
import 'package:cloud_firestore/cloud_firestore.dart';

class PrintOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String> createOrder({
    required String userId,
    String? storyId,
    required String title,
    required String fullName,
    required String address,
    required String phone,
    required int quantity,
  }) async {
    final ref = await _db.collection('print_orders').add({
      'userId': userId,
      'storyId': storyId,
      'title': title,
      'fullName': fullName,
      'address': address,
      'phone': phone,
      'quantity': quantity,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
