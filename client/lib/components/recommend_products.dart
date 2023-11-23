import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:client/models/product.dart';
import 'package:client/services/preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:client/style.dart';

Widget popularCard(Size size, Product product, BuildContext context) {
  return Padding(
    padding: const EdgeInsets.only(right: 10),
    child: GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/itemDetail', arguments: product);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(
                height: size.height * 0.14,
                width: size.width * 0.23,
                child: Image.network(
                  "http://" +
                      ip +
                      "/" +
                      product.image
                          .replaceAllMapped(RegExp(r'\\'), (match) => '/'),
                  fit: BoxFit.cover,
                )),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text((() {
              var x = product.title;
              if (x.length >= 14) {
                return x.substring(0, 13) + "...";
              }
              return x;
            })(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: black,
                )),
          ),
          RichText(
            text: TextSpan(
                text: "\$ ",
                style: const TextStyle(
                  fontSize: 16,
                  color: dolar,
                  fontWeight: FontWeight.bold,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: product.price.toString(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: black,
                    ),
                  )
                ]),
          )
        ],
      ),
    ),
  );
}

class RecommendProduct extends StatefulWidget {
  final Size size;
  final Product item;
  const RecommendProduct({Key? key, required this.size, required this.item})
      : super(key: key);

  @override
  State<RecommendProduct> createState() => _RecommendProductState(size, item);
}

class _RecommendProductState extends State<RecommendProduct> {
  final Size size;
  late Future myFuture;
  final Product item;
  _RecommendProductState(this.size, this.item);

  @override
  void initState() {
    super.initState();
    myFuture = getData(item);
  }

  Future getData(Product item) async {
    final _preferencesService = PreferencesService();
    final Set token = await _preferencesService.getToken();
    final response = await http
        .get(Uri.http(ip, 'api/products/recommend/${token.elementAt(1)}'), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + token.elementAt(0),
    });
    final jsondata = jsonDecode(response.body);
    List<Product> products = [];
    if (jsondata['success']) {
      for (var u in jsondata['Products']) {
        Product product = Product(
            u['title'], u['description'], u['price'], u['image'], u['_id'], 0);
        products.add(product);
      }
      return products;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height * 0.24,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: FutureBuilder(
            future: myFuture,
            builder: (context, snapshots) {
              if (snapshots.data == null) {
                return const Text("Loading...");
              } else {
                var data = snapshots.data as List<Product>;
                if (data.isEmpty) {
                  return const Text("There is no Recommend.");
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return popularCard(size, data[index], context);
                    },
                  );
                }
              }
            },
          )),
    );
  }
}
