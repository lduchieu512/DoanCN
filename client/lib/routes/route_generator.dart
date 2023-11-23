import 'package:flutter/material.dart';
import 'package:client/Screens/Account/account_screen.dart';
import 'package:client/Screens/Authentication/authentication_screen.dart';
import 'package:client/Screens/Bill/bill_screen.dart';
import 'package:client/Screens/Login/login_screen.dart';
import 'package:client/Screens/Signup/signup_screen.dart';
import 'package:client/Screens/Welcome/welcome_screen.dart';
import 'package:client/route/item_detail.dart';
import '../main.dart';
import '../models/product.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting argument passed in while calling Navigator.pushNamed
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const MyHomePage());
      case '/welcome':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/detail':
        if (args is String) {
          return MaterialPageRoute(builder: (_) => DetailPage(category: args));
        }
        return _errorRoute();
      case '/Bill':
        return MaterialPageRoute(builder: (_) => const BillScreen());
      case "/Account":
        return MaterialPageRoute(builder: (_) => const AccountScreen());
      case "/Changepassword":
        return MaterialPageRoute(builder: (_) => const AuthenticationScreen());
      case '/itemDetail':
        if (args is Product) {
          return MaterialPageRoute(builder: (_) => ItemDetail(item: args));
        }
        return _errorRoute();
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Error'),
          ),
          body: const Center(
            child: Text('Error'),
          ));
    });
  }
}
