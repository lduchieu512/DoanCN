import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:client/style.dart';
import 'package:client/Screens/Login/components/background.dart';
import 'package:flutter_svg/svg.dart';
import 'package:client/components/already_have_an_account.dart';
import 'package:client/components/rounded_input_field.dart';
import 'package:client/components/rounded_password_field.dart';
import 'package:client/components/roundedbutton.dart';
import 'package:client/models/user_model.dart';
import 'package:client/services/preferences_service.dart';
import 'package:http/http.dart' as http;

class Body extends StatelessWidget {
  const Body({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String username = "", password = "";
    return Background(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "LOGIN",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          SvgPicture.asset(
            "assets/icons/login.svg",
            height: size.height * 0.35,
          ),
          SizedBox(height: size.height * 0.03),
          RoundedInputField(
            hintText: "Your Username",
            onChanged: (value) {
              username = value;
            },
          ),
          RoundedPasswordField(onChanged: (value) {
            password = value;
          }),
          RoundedButton(
            text: "LOGIN",
            press: () async {
              UserModel user =
                  UserModel(username: username, password: password);
              final response = await authenticateUser(user);
              handle(response, context);
            },
          ),
          SizedBox(height: size.height * 0.03),
          AlreadyHaveAnAccountCheck(
            press: () {
              Navigator.of(context).pushNamed('/signup');
            },
          )
        ],
      ),
    );
  }
}

void handle(data, BuildContext context) {
  final bool success = data['success'];
  final _preferencesService = PreferencesService();
  if (success) {
    _preferencesService.saveCustomer(
        data['accessToken'], data['push']['_id'].toString());
    Navigator.of(context).pushNamed("/");
  } else {
    print(data['message']);
  }
}

Future<Map> authenticateUser(UserModel user) async {
  final newUser = json.encode(user);
  final Uri apiURL = Uri.http(ip, "api/customer/login");
  final response = await http.post(apiURL,
      headers: {"Content-Type": "application/json"}, body: newUser);
  if (response.statusCode == 200) {
    print("authenticate");
    final String responseString = response.body;
    return jsonDecode(responseString);
  } else {
    final String responseString = response.body;
    return jsonDecode(responseString);
  }
}
