import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:client/components/product_not_Rating.dart';
import 'package:client/components/roundedbutton.dart';
import 'package:client/style.dart';
import 'package:client/Screens/Bill/components/background.dart';
import 'package:client/models/bill_history_model.dart';
import 'package:client/models/product.dart';
import 'package:client/models/userbody.dart';
import 'package:client/services/preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  Future<UserBody> getUser() async {
    final _preferencesService = PreferencesService();
    Set set = await _preferencesService.getToken();
    Map<String, dynamic> customerId = {"customerId": set.elementAt(1)};
    final response = await http.post(Uri.http(ip, 'api/customer'),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer ${set.elementAt(0)}'
        },
        body: jsonEncode(customerId));
    final jsondata = jsonDecode(response.body);
    UserBody userbody = UserBody(jsondata['customer']['username'],
        jsondata['customer']['_id'].toString(), jsondata['customer']['createdAt']);
    return userbody;
  }

  Future getData() async {
    final _preferencesService = PreferencesService();
    Set set = await _preferencesService.getToken();
    Map<String, dynamic> customerId = {"customerId": set.elementAt(1)};
    final response = await http.post(Uri.http(ip, 'api/bill/get'),
        headers: {
          "Content-Type": "application/json",
          HttpHeaders.authorizationHeader: 'Bearer ${set.elementAt(0)}'
        },
        body: jsonEncode(customerId));
    final jsondata = jsonDecode(response.body);
    List<BillHistory> data = [];
    if (jsondata['success']) {
      for (var x in jsondata['Bills']) {
        List<Product> products = [];
        for (var u in x['products']) {
          Product product = Product(
              u['product'][0]['title'],
              u['product'][0]['description'],
              u['price'],
              u['product'][0]['image'],
              u['product'][0]['_id'],
              u['quantity']);

          products.add(product);
        }
        BillHistory bill = BillHistory(
            date: x['date'],
            id: x['_id'],
            products: products,
            total: x['total'].toDouble(),
            customerName: x['customerEntity'][0]['username'],
            status: x['status']);
        data.add(bill);
      }
      return data;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundedButton(
              text: "Rating",
              press: () {
                showGeneralDialog(
                    barrierColor: Colors.black.withOpacity(0.5),
                    transitionBuilder: (context, a1, a2, widget) {
                      return Transform.scale(
                        scale: a1.value,
                        child: Opacity(
                          opacity: a1.value,
                          child: PNRDialog(
                            size: size,
                          ),
                        ),
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                    barrierDismissible: true,
                    barrierLabel: '',
                    context: context,
                    pageBuilder: (context, animation1, animation2) {
                      return Container();
                    });
              }),
          FutureBuilder(
              future: getUser(),
              builder: (context, datas) {
                if (!datas.hasData) {
                  return const Text("Loading...");
                } else {
                  var user = datas.data as UserBody;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            "Hi ${user.username}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          )
                        ],
                      )
                    ],
                  );
                }
              }),
          Expanded(
              flex: 8,
              child: FutureBuilder(
                  future: getData(),
                  builder: (context, snapshots) {
                    if (!snapshots.hasData) {
                      return const Text("Loading...");
                    } else {
                      var items = snapshots.data as List<BillHistory>;
                      if (items.isEmpty) {
                        return const Center(
                          child: Text("Bill is Empty"),
                        );
                      } else {
                        return ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: white,
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: shadowColor,
                                          blurRadius: 4,
                                          offset: Offset(0, 3),
                                        )
                                      ]),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          BodyCardHeader(
                                              items: items, index: index),
                                          BodyCard(items: items, index: index)
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      }
                    }
                  })),
                  Container(height: size.height * 0.1,)
        ],
      ),
    );
  }
}

class BodyCardHeader extends StatelessWidget {
  const BodyCardHeader({
    Key? key,
    required this.items,
    required this.index,
  }) : super(key: key);
  final int index;

  final List<BillHistory> items;

  @override
  Widget build(BuildContext context) {
    var col = yellow;

    // DateTime parseDate =
    //     DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").parse(items[index].date);
    // var inputDate = DateTime.parse(parseDate.toString());
    // var outputFormat = DateFormat('MM/dd/yyyy hh:mm a');
    // var outputDate = outputFormat.format(inputDate);
    return ListTile(
        title: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Order",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: black,
            ),
          ),
          Text(
            items[index].date,
            style: const TextStyle(
              color: lightGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ]),
        Container(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Total: \$" + items[index].total.toString(),
                  style: const TextStyle(
                    color: black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: (() {
                      if (items[index].status == "Waiting") {
                        col = green;
                      }
                      switch (items[index].status) {
                        case "Accepted":
                          col = green;
                          break;
                        case "Rejected":
                          col = dolar;
                          break;
                        default:
                          col = yellow;
                          break;
                      }
                      return col;
                    }()))),
                    child: Text(
                      items[index].status.toString(),
                      style: TextStyle(color: col),
                    ))
              ],
            ))
      ],
    ));
  }
}

class BodyCard extends StatelessWidget {
  const BodyCard({Key? key, required this.items, required this.index})
      : super(key: key);
  final int index;
  final List<BillHistory> items;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: items[index].products.length,
            itemBuilder: (context, idx) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(size.width * 0.1),
                      child: SizedBox(
                          height: size.height * 0.14,
                          width: size.width * 0.2,
                          child: Image.network(
                            "http://" +
                                ip +
                                "/" +
                                items[index]
                                    .products[idx]
                                    .image
                                    .replaceAllMapped(
                                        RegExp(r'\\'), (match) => '/'),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    items[index].products[idx].title,
                                    style: const TextStyle(
                                      color: black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20),
                                    child: Text(
                                      items[index].products[idx].description,
                                      style: const TextStyle(
                                          color: lightGray,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    "\$ " +
                                        items[index]
                                            .products[idx]
                                            .price
                                            .toString(),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: black),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                                "Qty: ${items[index].products[idx].quantity.toString()}"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            })
      ],
    );
  }
}
