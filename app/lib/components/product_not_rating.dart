// ignore_for_file: file_names

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:client/components/rating_card.dart';
import 'package:client/models/product.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:http/http.dart' as http;

class PNRDialog extends StatefulWidget {
  final Size size;
  const PNRDialog({
    Key? key,
    required this.size,
  }) : super(key: key);

  @override
  State<PNRDialog> createState() => _PNRDialogState(size);
}

class _PNRDialogState extends State<PNRDialog> {
  final Size size;
  late final Future future;

  _PNRDialogState(this.size);

  @override
  void initState() {
    super.initState();
    future = getData();
  }

  Future getData() async {
    final _preferencesService = PreferencesService();
    final Set token = await _preferencesService.getToken();
    final response =
        await http.get(Uri.http(ip, 'api/products/not-rating'), headers: {
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
    return Dialog(
      insetPadding:
          const EdgeInsets.only(right: 0, left: 0, bottom: 0, top: 70),
      shape: const OutlineInputBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(29), topRight: Radius.circular(29)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, left: 30, right: 30, bottom: 0),
        child: SizedBox(
            width: size.width,
            height: size.height,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SizedBox(
                  height: size.height * 0.8,
                  child: FutureBuilder(
                    future: future,
                    builder: (context, snapshots) {
                      if (snapshots.data == null) {
                        return const Center(
                          child: Text("Loading..."),
                        );
                      } else {
                        var items = snapshots.data as List<Product>;
                        if (items.isEmpty) {
                          return const Center(
                            child: Text("All Products had been rating..."),
                          );
                        }
                        else {
                          return ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return RatingCard(
                                  size: size, product: items[index]);
                            },
                          );
                        }
                      }
                    },
                  )),
            )),
      ),
    );
  }
}
