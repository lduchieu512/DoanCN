import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:client/components/cart_dialog.dart';
import 'package:client/models/Shop.dart';
import 'package:client/models/category_model.dart';
import 'package:client/models/id.dart';
import 'package:client/routes/route_generator.dart';

import 'package:client/models/product.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:client/utils/white_box.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.white),
      debugShowCheckedModeBanner: false,
      initialRoute: '/welcome',
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}

Future getData() async {
  final _preferencesService = PreferencesService();
  final Set token = await _preferencesService.getToken();
  final response = await http.get(Uri.http(ip, 'api/products'), headers: {
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

Future getShop() async {
  final _preferencesService = PreferencesService();
  final Set token = await _preferencesService.getToken();
  final response = await http.get(Uri.http(ip, 'api/category/'), headers: {
    HttpHeaders.authorizationHeader: 'Bearer ' + token.elementAt(0),
  });
  final jsondata = jsonDecode(response.body);
  List<CategoryEntity> categoryList = [];
  if (jsondata['success']) {
    for (var u in jsondata['categoryList']) {
      
      CategoryEntity category = CategoryEntity(u['_id'].toString(), u['categoryTitle']);
      categoryList.add(category);
    }
    return categoryList;
  } else {
    return null;
  }
}

Widget productCard(String category, Size size) {
  return FutureBuilder(
    future: getDataFromShop(category),
    builder: (context, snapshots) {
      if (snapshots.data == null)
        {
          return const Text("Loading...");
        }
      else {
        var items = snapshots.data as List<Product>;
        if(items.isEmpty) {
          return const Center(child: Text("Category have no product"),);
        }
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed('/itemDetail', arguments: items[index]);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                          height: size.height * 0.3,
                          width: size.width * 0.533,
                          child: Image.network(
                            "http://" +
                                ip +
                                "/" +
                                items[index].image.replaceAllMapped(
                                    RegExp(r'\\'), (match) => '/'),
                            fit: BoxFit.cover,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text((() {
                        var x = items[index].title;
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
                              text: items[index].price.toString(),
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
          },
        );
      }
    },
  );
}

Future getDataFromShop(String category) async {
  final response = await http.get(
    Uri.http(ip, 'api/products/detail/'+category),
  );

  final jsondata = jsonDecode(response.body);
  List<Product> products = [];
  if (jsondata['success']) {
    for (var u in jsondata['Products']) {
      Product product = Product(
          u['title'], u['description'], u['price'], u['image'], u['_id'], 0);
      products.add(product);
    }
    return products;
  }
}

class DetailPage extends StatelessWidget {
  final String category;

  const DetailPage({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Page'),
        ),
        body: SafeArea(
          child: Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: (Column(
                      children: [
                        productCard(category, size),
                      ],
                    )),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Widget ShopKeeper() {
  return FutureBuilder(
      future: getShop(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const Text("Loading...");
        } else {
          var items = snapshot.data as List<CategoryEntity>;
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                return categoryCard(context, items[index], items[index].category.toString());
              });
        }
      });
}

Widget popularCard(Size size) {
  return FutureBuilder(
      future: getData(),
      builder: (context, snapshots) {
        if (snapshots.data == null) {
          return const Text("Loading...");
        } else {
          var items = snapshots.data as List<Product>;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/itemDetail', arguments: items[index]);
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
                                  items[index].image.replaceAllMapped(
                                      RegExp(r'\\'), (match) => '/'),
                              fit: BoxFit.cover,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text((() {
                          var x = items[index].title;
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
                                text: items[index].price.toString(),
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
            },
          );
        }
      });
}

Widget categoryCard(context, CategoryEntity item, String text) {
  return Padding(
    padding: const EdgeInsets.only(right: 10.0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: Container(
        color: primarycolor,
        padding: const EdgeInsets.only(left: 2.5, right: 2.5),
        child: IntrinsicHeight(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed('/detail', arguments: item.category);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Container(
                //     width: 40,
                //     height: 40,
                //     decoration: const BoxDecoration(
                //       shape: BoxShape.circle,
                //       color: white,
                //     ),
                //     child: FittedBox(
                //       child: Image.asset('assets/images/Hambuger.png'),
                //     ),
                //   ),
                // ),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        text,
                        style: const TextStyle(
                          color: white,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    BuildContext parentContent = context;
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
                      child: CartDialog(
                        size: size,
                        parentContext: parentContent,
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
          },
        );
    final items = [
      const Icon(Icons.home),
      const Icon(Icons.content_paste),
      const Icon(Icons.person),
    ];
    return Scaffold(
        extendBodyBehindAppBar: true,
        extendBody: true,
        // appBar: AppBar(
        //   elevation: 0,
        //   automaticallyImplyLeading: false,
        //   backgroundColor: Colors.white,
        //   title: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       SizedBox(
        //         height: 34.0,
        //         width: 104.0,
        //         child: FittedBox(
        //           child: Image.asset(
        //             'assets/images/Logo.png',
        //             fit: BoxFit.cover,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
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
        body: SafeArea(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                        image: AssetImage('assets/images/Banner.jpg'),
                        fit: BoxFit.fill,
                      )),
                      height: 183.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 30,
                              left: 40,
                            ),
                            child: SizedBox(
                              width: 180,
                              child: RichText(
                                  text: const TextSpan(
                                      text: 'Fastest Delivery',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 26,
                                      ),
                                      children: <TextSpan>[
                                    TextSpan(
                                        text: ' Food',
                                        style: TextStyle(
                                          color: primarycolor,
                                        ))
                                  ])),
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 70,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                                primary: primarycolor,
                              ),
                              child: const Text(
                                'Order Now',
                                style: TextStyle(
                                  color: white,
                                ),
                              ),
                              onPressed: () {
                                getData();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  WhiteBox(5),
                  SizedBox(
                    height: 120.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Categories',
                              style: TextStyle(
                                color: black,
                                fontSize: 26,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [ShopKeeper()],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    height: 220.0,
                    alignment: Alignment.centerLeft,
                    child: Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Popular',
                              style: TextStyle(
                                color: black,
                                fontSize: 26,
                              ),
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  popularCard(size),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
