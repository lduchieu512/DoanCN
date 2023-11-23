import 'dart:convert';
import 'dart:io';

import 'package:client/models/userbody.dart';
import 'package:flutter/material.dart';
import 'package:client/Screens/Account/components/background.dart';
import 'package:client/components/account_button.dart';
import 'package:client/services/preferences_service.dart';
import 'package:client/style.dart';
import 'package:http/http.dart' as http;

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

Future getCustomer() async {
  final _preferences = PreferencesService();
  final Set token = await _preferences.getToken();
  if (token != "") {
    final Uri apiUrl = Uri.http(ip, "api/customer");
    final response =
        await http.post(apiUrl, body: token.elementAt(1).toString());
    final jsondata = jsonDecode(response.body);
    
    
  }
}

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

class _BodyState extends State<Body> {
  final _preferences = PreferencesService();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Background(
          child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular((size.height * 0.08) / 2),
                      child: Container(
                        width: size.height * 0.08,
                        height: size.height * 0.08,
                        child: Image.asset(
                          "assets/images/woman.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.04,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Good Morning",
                          style: TextStyle(
                            color: lightGray,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                            user.username,
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
                      ],
                    )
                  ],
                ),
              ),
            ),
            Column(
              children: const [
                AccountInfoCard(
                    icon: Icons.alarm, color: Colors.yellow, text: "time"),
                AccountInfoCard(
                    icon: Icons.compare, color: purple, text: "total"),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AccountButton(
                      text: "Profile",
                      color: white,
                      textColor: accountButtonActive,
                      press: () {},
                      icon: Icons.people_alt_outlined),
                  AccountButton(
                      text: "Notifications",
                      color: white,
                      textColor: accountButtonActive,
                      press: () {},
                      icon: Icons.notifications_outlined),
                  AccountButton(
                      text: "Change Password",
                      color: white,
                      textColor: accountButtonActive,
                      press: () {
                        Navigator.of(context).pushNamed("/Changepassword");
                      },
                      icon: Icons.lock),
                  AccountButton(
                      text: "Sign Out",
                      color: accountButtonActive,
                      textColor: white,
                      press: () async {
                        await _preferences.removeToken();
                        Navigator.of(context).pushNamed("/welcome");
                      },
                      icon: Icons.logout),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class AccountInfoCard extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;
  const AccountInfoCard(
      {Key? key, required this.icon, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular((size.height * 0.08) / 2),
                      child: Container(
                        color: color,
                        width: size.height * 0.08,
                        height: size.height * 0.08,
                        alignment: Alignment.center,
                        child: Icon(
                          icon,
                          size: 20,
                          color: white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.04,
                    ),
                    Text(
                      text,
                      style: TextStyle(
                        color: black,
                        fontWeight: FontWeight.bold,
                        fontSize: size.height * 0.04,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
