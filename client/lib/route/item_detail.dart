import 'dart:convert';
import 'dart:io';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:client/components/cart_dialog.dart';
import 'package:client/components/recommend_products.dart';
import 'package:client/models/cart_model.dart';
import 'package:client/models/product.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:http/http.dart' as http;

class ItemDetail extends StatefulWidget {
  final Product item;
  const ItemDetail({Key? key, required this.item}) : super(key: key);

  @override
  _ItemDetailState createState() => _ItemDetailState(item);
}

class _ItemDetailState extends State<ItemDetail> {
  int index = 0;
  final _preferencesService = PreferencesService();
  final Product item;
  int _quantity = 1;

  Future getRecommend() async {
    final Set token = await _preferencesService.getToken();
    final response = await http.get(Uri.http(ip, 'api/ratings/all'), headers: {
      HttpHeaders.authorizationHeader: 'Bearer ' + token.elementAt(1),
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
  void initState() {
    super.initState();
    _populateitem();
  }

  void _populateitem() async {
    final data = await _preferencesService.getSettings();
    if (data == null) {
    } else {}
  }

  _ItemDetailState(this.item);
  @override
  Widget build(BuildContext context) {
    final items = [
      const Icon(Icons.home),
      const Icon(Icons.content_paste),
      const Icon(Icons.person),
    ];
    BuildContext parentContent = context;
    Size size = MediaQuery.of(context).size;
    Widget buildNavigateButton() => FloatingActionButton(
          child: const Icon(Icons.shopping_cart),
          backgroundColor: Colors.green,
          onPressed: () {
            showGeneralDialog(
                barrierColor: Colors.black.withOpacity(0.5),
                transitionBuilder: (context, a1, a2, widget) {
                  return Transform.scale(
                    scale: a1.value,
                    child: Opacity(
                      opacity: a1.value,
                      child: CartDialog(size: size, parentContext: parentContent,),
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
          },
        );
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        floatingActionButton: buildNavigateButton(),
        bottomNavigationBar: Theme(
          data: Theme.of(context)
              .copyWith(iconTheme: const IconThemeData(color: white)),
          child: CurvedNavigationBar(
            buttonBackgroundColor: purple,
            color: Colors.blueAccent,
            backgroundColor: transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: const Duration(milliseconds: 300),
            items: items,
            index: index,
            height: size.height * 0.08,
            onTap: (index) => setState(() {
              this.index = index;
              switch (index) {
                case 0:
                  Navigator.of(context).pushNamed("/");
                  break;
                case 1:
                  Navigator.of(context).pushNamed("/Bill");
                  break;
                case 2:
                  Navigator.of(context).pushNamed("/Account");
                  break;
                default:
                  return;
              }
            }),
          ),
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: black,
          ),
          title: SizedBox(
            height: 34.0,
            width: 104.0,
            child: FittedBox(
              child: Image.asset(
                'assets/images/Logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          elevation: 0,
          automaticallyImplyLeading: true,
          centerTitle: true,
          backgroundColor: yellow,
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.fill,
              )),
              child: Center(
                child: Column(
                  children: [
                    SizedBox(
                        width: 200,
                        height: 250,
                        child: Image.network(
                          "http://" +
                              ip +
                              "/" +
                              item.image.replaceAllMapped(
                                  RegExp(r'\\'), (match) => '/'),
                          fit: BoxFit.fill,
                        )),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        color: primarycolor,
                        width: 180,
                        height: 46,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => setState(() {
                                if (_quantity != 1) {
                                  _quantity -= 1;
                                }
                              }),
                              child: const Icon(
                                Icons.remove,
                                color: white,
                                size: 16,
                              ),
                            ),
                            Text(
                              _quantity.toString(),
                              style: const TextStyle(
                                color: white,
                                fontSize: 26,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() {
                                _quantity += 1;
                              }),
                              child: const Icon(
                                Icons.add,
                                color: white,
                                size: 16,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  "Category",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: lightGray,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            RichText(
                              text: TextSpan(
                                text: "\$",
                                style: const TextStyle(
                                    color: primarycolor, fontSize: 24),
                                children: [
                                  TextSpan(
                                    text: item.price.toString(),
                                    style: const TextStyle(
                                      color: black,
                                      fontSize: 36,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          iconScore("4.8", "star.png", Colors.yellow),
                          iconScore("1,440 Calo", "fire.png", Colors.orange[900]),
                          iconScore("24 Hours", "clock.png", primarycolor)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 60, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          RichText(
                            maxLines: 6,
                            softWrap: true,
                            text: TextSpan(
                              text: item.description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: lightGray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            maximumSize: const Size(250.0, 54.0),
                            primary: primarycolor,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)))),
                        onPressed: () {
                          CartItem cartItem = CartItem(
                              item.id.toString(),
                              item.title,
                              item.image,
                              item.description,
                              item.price,
                              _quantity);
                          _saveSettings(cartItem);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Add To Cart",
                                style: TextStyle(fontSize: 16, color: white),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 24,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),

                    
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _saveSettings(CartItem cartitem) {
    String id = cartitem.id;
    String title = cartitem.title;
    String image = cartitem.image;
    String description = cartitem.description;
    int quantity = cartitem.quantity;
    int price = cartitem.price;
    final newSettings =
        CartItem(id, title, image, description, price, quantity);

    _preferencesService.addSettings(newSettings);
  }
}

Widget iconScore(score, icon, color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      ImageIcon(
        AssetImage("assets/images/$icon"),
        size: 16,
        color: color,
      ),
      const SizedBox(
        width: 5,
      ),
      Text(
        score,
        style: const TextStyle(fontSize: 16),
      )
    ],
  );
}
