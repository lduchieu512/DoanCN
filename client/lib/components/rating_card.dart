import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:client/models/product.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

class RatingCard extends StatelessWidget {
  final Size size;
  final Product product;
  const RatingCard({
    Key? key,
    required this.size,
    required this.product,
  }) : super(key: key);

  Future ratingProduct(
      Product product, double rating, BuildContext context) async {
    final _preferencesService = PreferencesService();
    Set set = await _preferencesService.getToken();
    Map<String, dynamic> condition = {
      "product_id": product.id,
      "score": rating
    };
    final response = await http.post(Uri.http(ip, 'api/ratings'),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer ${set.elementAt(0)}'
        },
        body: jsonEncode(condition));
    print("rating");
    final jsondata = jsonDecode(response.body);
    if (jsondata['success']) {
      print("success");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(jsondata['message']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: size.width * 0.25,
                height: size.height * 0.14,
                color: itemBackground,
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.network(
                    'http://${ip}/${product.image.replaceAllMapped(RegExp(r'\\'), (match) => "/")}',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: size.width * 0.05,
          ),
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: lightGray),
                ),
                const SizedBox(
                  height: 10,
                ),
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    print("rating product " + rating.toString());
                    ratingProduct(product, rating, context);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
