import 'package:flutter/material.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:client/models/cart_model.dart';

class CartDialogCard extends StatelessWidget {
  final Size size;
  final CartItem data;
  const CartDialogCard({
    Key? key,
    required this.size,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // print("http://192.168.1.2:5000/" +
    //     data.image.replaceAllMapped(RegExp(r'\\'), (match) => "/"));
    final _preferencesService = PreferencesService();
    print("http://" +
        ip +
        "/" +
        data.image.replaceAllMapped(RegExp(r'\\'), (match) => "/"));
    return Row(
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
                    "http://" +
                        ip +
                        "/" +
                        data.image
                            .replaceAllMapped(RegExp(r'\\'), (match) => "/"),
                    fit: BoxFit.cover,
                  )),
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
                data.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: lightGray),
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(
                    text: "\$",
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primarycolor),
                    children: [
                      TextSpan(
                          text: data.price.toString(),
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: black))
                    ]),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        GestureDetector(
                          onTap: () {
                          },
                          child: const Icon(
                            Icons.remove,
                            size: 20,
                          ),
                        ),
                        Text(
                          data.quantity.toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
