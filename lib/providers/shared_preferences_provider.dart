import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  SharedPreferencesProvider() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      notifyListeners();
    });
  }

  String? get dataPromemoria => _prefs?.getString('dataPromemoria');

  void setDataPromemoria(String value) {
    _prefs?.setString('dataPromemoria', value);
    notifyListeners();
  }
}
