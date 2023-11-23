import 'package:flutter/material.dart';
import 'package:client/components/text_field_container.dart';
import 'package:client/style.dart';

class RoundedPasswordField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final double horizontal;
  const RoundedPasswordField({
    Key? key,
    required this.onChanged,
    this.horizontal = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      horizontal: horizontal,
      child: TextField(
        onChanged: onChanged,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Password",
          icon: const Icon(
            Icons.lock,
            color: purple,
          ),
          suffixIcon: const Icon(
            Icons.visibility,
            color: purple,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
