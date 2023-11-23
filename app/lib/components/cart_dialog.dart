import 'dart:io';

import 'package:flutter/material.dart';
import 'package:client/components/cart_dialog_card.dart';
import 'package:client/components/cart_info_cart.dart';
import 'package:client/components/roundedbutton.dart';
import 'package:client/models/bill_model.dart';
import 'package:client/models/cart_model.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_paypal/flutter_paypal.dart';

class CartDialog extends StatefulWidget {
  const CartDialog({Key? key, required this.size, required this.parentContext})
      : super(key: key);

  final Size size;
  final BuildContext parentContext;

  @override
  _CartDialogState createState() => _CartDialogState(size, parentContext);
}

class _CartDialogState extends State<CartDialog> {
  final _preferencesService = PreferencesService();
  final Size size;
  final BuildContext parentContext;
  List<CartItem> data = [];

  @override
  void initState() {
    super.initState();
    _populateitem();
  }

  void _populateitem() async {
    final data = await _preferencesService.getSettings();
    if (data == null) {
    } else {
      this.data = data;
    }
  }

  _CartDialogState(this.size, this.parentContext);

  @override
  Widget build(BuildContext context) {
    double total = 0;
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text(
                    "Cart",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: lightGray,
                        fontSize: 34),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const CartInfoCard(),
                const SizedBox(
                  height: 10,
                ),
                const CartInfoCard(
                  icon: Icons.location_on_sharp,
                  color: lightGray,
                  text: "13 St Marks street",
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "Order",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: lightGray,
                      fontSize: 34),
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SizedBox(
                        height: size.height * 0.25,
                        child: (() {
                          if (data.isEmpty) {
                            return const Center(
                                child: Text(
                              "Your Cart Is Empty!",
                              style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: lightGray),
                            ));
                          } else {
                            return ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Dismissible(
                                      key: UniqueKey(),
                                      direction: DismissDirection.endToStart,
                                      onDismissed: (_) {
                                        setState(() {
                                          _preferencesService
                                              .removeItemSettings(data[index]);
                                          data.removeAt(index);
                                        });
                                      },
                                      background: Container(
                                        color: Colors.red,
                                        child: const Padding(
                                          padding: EdgeInsets.only(right: 16),
                                          child: Icon(
                                            Icons.delete,
                                            size: 30,
                                            color: white,
                                          ),
                                        ),
                                      ),
                                      child: CartDialogCard(
                                          size: size, data: data[index]));
                                });
                          }
                        }())),
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total"),
                              Text(() {
                                for (int i = 0; i < data.length; i++) {
                                  total =
                                      total + data[i].price * data[i].quantity;
                                }
                                return "\$ ${total.toString()}";
                              }()),
                            ]),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Delivery"),
                              Text("From free to \$5"),
                            ]),
                        RoundedButton(
                          text: "Pay",
                          press: () async {
                            double total = await getCartDetail();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext insideContext) => UsePaypal(
                                    sandboxMode: true,
                                    clientId:
                                        "AQ5UiV2EuXG2VVWejFRQ4z_Z4kOnduZnhpa0YGpG7_3B1ZOy60xHM6NuL1lqaERQ5-RbNNHFW2VexWca",
                                    secretKey:
                                        "EM9JGkQsXzKE4PhgQwX9EGVXwPslWUc9wIY4bfni8j5D5RGzVXaZ9BO_9UDfQde7TTH7XlEXbkWQMfxY",
                                    returnURL: "http://localhost:5000/api/payment/success",
                                    cancelURL: "http://localhost:5000/api/payment/cancel",
                                    transactions: [
                                      {
                                        "amount": {
                                          "total": total,
                                          "currency": "USD",
                                          "details": {
                                            "subtotal": total,
                                            "shipping": '0',
                                            "shipping_discount": 0
                                          }
                                        },
                                        "description":
                                            "The payment transaction description.",
                                      }
                                    ],
                                    note:
                                        "Contact us for any questions on your order.",
                                    onSuccess: (Map params) async {
                                      postData(context);
                                    },
                                    onError: (error) {
                                      print("onError: $error");
                                    },
                                    onCancel: (params) {
                                      print('cancelled: $params');
                                    }),
                              ),
                            );
                          },
                          color: Colors.yellow,
                        )
                      ],
                    ))
              ],
            )),
      ),
    );
  }
}

Future getCartDetail() async {
  final _preferences = PreferencesService();
  List<CartItem> data = await _preferences.getSettings();
  List<Miniproduct> products = [];
  double total = 0;
  if(data.isNotEmpty) {
    for (var i = 0; i < data.length; i++) {
      products.add(Miniproduct(
          productId: data[i].id,
          quantity: data[i].quantity,
          price: data[i].price));
      total = total + data[i].price * data[i].quantity;
    }
  }
  return total;
}

Future postData(BuildContext context) async {
  final _preferences = PreferencesService();
  List<CartItem> data = await _preferences.getSettings();
  List<Miniproduct> products = [];
  double total = 0;
  if (data.isNotEmpty) {
    for (var i = 0; i < data.length; i++) {
      products.add(Miniproduct(
          productId: data[i].id,
          quantity: data[i].quantity,
          price: data[i].price));
      total = total + data[i].price * data[i].quantity;
    }
    final Set token = await _preferences.getToken();
    final Bill bill =
        Bill(customerId: token.elementAt(1), products: products, total: total);
    List<Bill> list = [bill];
    if (token != "") {
      final Uri apiURL = Uri.http(ip, "api/bill");
      final response = await http.post(apiURL,
          headers: {
            "Content-Type": "application/json",
            HttpHeaders.authorizationHeader: "Bearer " + token.elementAt(0)
          },
          body: Bill.encode(list).substring(1, Bill.encode(list).length - 1));
      final String responseString = response.body;
      _preferences.removeCart();
      Navigator.of(context).pushNamed("/");
    } else {
      Navigator.of(context).pushNamed("/login");
    }
  }
}
