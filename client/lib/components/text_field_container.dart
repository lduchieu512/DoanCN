import 'package:flutter/material.dart';
import 'package:client/style.dart';

class TextFieldContainer extends StatelessWidget {
  final Widget child;
  final double horizontal;
  const TextFieldContainer({
    Key? key,
    required this.child,
    this.horizontal = 20,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(29),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: 5),
          child: Container(
            width: size.width * 0.8,
            color: lightColor,
            child: child,
          ),
        ),
      ),
    );
  }
}
