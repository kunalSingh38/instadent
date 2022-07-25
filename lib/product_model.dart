import 'add_to_cart_helper.dart';

class DummyCart {
  late String productId;
  late String productQty;
  late String productPrice;
  late String productDisscount;

  DummyCart(this.productId, this.productQty, this.productPrice,
      this.productDisscount);

  DummyCart.fromMap(Map<String, dynamic> map) {
    productId = map['productId'];
    productQty = map['productQty'];
    productPrice = map['productPrice'];
    productDisscount = map['productDisscount'];
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseHelper.columnProductId: productId,
      DatabaseHelper.columnProductQty: productQty,
      DatabaseHelper.columnProductPrice: productPrice,
      DatabaseHelper.columnProductDisscount: productDisscount,
    };
  }
}
