class ProductModal {
  late int _id;
  late String _product_id;
  late String _quantity;
  late String _rate;
  late String _offer_price;

  ProductModal(
    this._product_id,
    this._quantity,
    this._rate,
    this._offer_price,
  );

  ProductModal.map(dynamic obj) {
    this._id = obj['id'];
    this._product_id = obj['product_id'];

    this._quantity = obj['quantity'];
    this._rate = obj['rate'];
    this._offer_price = obj['offer_price'];
  }

  int get id => _id;
  String get product_id => _product_id;

  String get quantity => _quantity;
  String get rate => _rate;
  String get offer_price => _offer_price;

  Map<String, dynamic> toMap() {
    var map = new Map<String, dynamic>();
    if (_id != null) {
      map['id'] = _id;
    }
    map['product_id'] = _product_id;
    map['quantity'] = _quantity;
    map['rate'] = _rate;
    map['offer_price'] = _offer_price;

    return map;
  }

  ProductModal.fromMap(Map<String, dynamic> map) {
    this._id = map['id'];
    this._product_id = map['product_id'];

    this._quantity = map['quantity'];
    this._rate = map['rate'];
    this._offer_price = map['offer_price'];
  }
}
