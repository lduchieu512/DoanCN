
import 'package:client/models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future saveCustomer(String token, String id) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setString("Token", token);
    preferences.setString("customerId", id);
  }

  Future<Set> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    final String? token = preferences.getString("Token");
    final String? customerId = preferences.getString("customerId");
    if (token == null) {
      return {"", ""};
    } else {
      Set set = {token, customerId};
      return set;
    }
  }
  

  Future removeToken() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove("Token");
    preferences.remove("customerId");
  }

  Future addSettings(CartItem cartItem) async {
    final preferences = await SharedPreferences.getInstance();
    final String? cartsString = preferences.getString("Cart_key");
    List<CartItem> listitem = [cartItem];
    if (cartsString != null) {
      final List<CartItem> cartitems = CartItem.decode(cartsString);
      bool _status = true;
      for (var i = 0; i < cartitems.length; i++) {
        if (cartitems[i].id == cartItem.id) {
          _status = false;
          cartitems[i].quantity += cartItem.quantity;
          await saveSettings(cartitems);
          print("Update Quantity \"" + cartitems[i].id + " Settings");
          break;
        }
      }
      if (_status) {
        cartitems.add(cartItem);
        await saveSettings(cartitems);
        print("+1 Settings");
      }
    } else {
      await saveSettings(listitem);
      print("Add New Settings");
    }
  }

  Future removeItemSettings(CartItem cartItem) async {
    final preferences = await SharedPreferences.getInstance();
    final String? cartsString = preferences.getString("Cart_key");
    if (cartsString == null) {
      return null;
    } else {
      final List<CartItem> cartitems = CartItem.decode(cartsString);
      cartitems.removeWhere((cartitem) => cartitem.id == cartItem.id);
      await saveSettings(cartitems);
    }
  }

  Future updateSettings(CartItem cartitem) async {
    final preferences = await SharedPreferences.getInstance();
    final String? cartsString = preferences.getString("Cart_key");
    String text = '';
    if (cartsString == null)
      return null;
    else {
      final List<CartItem> cartitems = CartItem.decode(cartsString);
      for (var i = 0; i < cartitems.length; i++) {
        if (cartitems[i].id == cartitem.id) {
          cartitems[i].quantity = cartitem.quantity;
          text = cartitems[i].id;
          break;
        }
      }
      await saveSettings(cartitems);
      print("Update \"" + text + "\" Settings");
    }
  }

  Future saveSettings(List<CartItem> listitem) async {
    final preferences = await SharedPreferences.getInstance();
    final String encodedData = CartItem.encode(listitem);
    await preferences.setString("Cart_key", encodedData);
    print("Preferences Saved");
  }

  Future getSettings() async {
    final preferences = await SharedPreferences.getInstance();
    final String? cartsString = preferences.getString("Cart_key");

    if (cartsString == null)
      return null;
    else {
      final List<CartItem> cartitems = CartItem.decode(cartsString);
      return cartitems;
    }
  }

  Future removeCart() async {
    final preferences = await SharedPreferences.getInstance();
    preferences.remove("Cart_key");
    print("Remove Settings");
  }
}
