import 'dart:convert';

class CartItem {
  final String title, description, image, id;
  int quantity;
  final int price;

  CartItem(
    this.id,
    this.title,
    this.image,
    this.description,
    this.price,
    this.quantity,
  );

  

  factory CartItem.fromJson(Map<String, dynamic> jsonData) {
    return CartItem(
      jsonData['id'],
      jsonData['title'],
      jsonData['image'],
      jsonData['description'],
      jsonData['price'],
      jsonData['quantity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'description': description,
        'price': price,
        'quantity': quantity,
      };

  static Map<String, dynamic> toMap(CartItem carditem) => {
        'id': carditem.id,
        'title': carditem.title,
        'image': carditem.image,
        'description': carditem.description,
        'price': carditem.price,
        'quantity': carditem.quantity,
      };

  static String encode(List<CartItem> carditems) => jsonEncode(
        carditems
            .map<Map<String, dynamic>>((carditem) => CartItem.toMap(carditem))
            .toList(),
      );
  static List<CartItem> decode(String carditems) =>
      (jsonDecode(carditems) as List<dynamic>)
          .map<CartItem>((item) => CartItem.fromJson(item))
          .toList();
}
