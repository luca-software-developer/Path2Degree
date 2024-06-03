import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Il provider SharedPreferencesProvider contente di gestire la persistenza
/// delle preferenze utente tra i riavvii dell'app.
class SharedPreferencesProvider extends ChangeNotifier {
  SharedPreferences? _prefs;

  /// Costruttore.
  SharedPreferencesProvider() {
    SharedPreferences.getInstance().then((prefs) {
      _prefs = prefs;
      notifyListeners();
    });
  }

  /// Data entro la quale gli esami devono essere considerati imminenti
  /// quindi oggetto di promemoria automatici.
  String? get dataPromemoria => _prefs?.getString('dataPromemoria');
  void setDataPromemoria(String value) {
    _prefs?.setString('dataPromemoria', value);
    notifyListeners();
  }
}
