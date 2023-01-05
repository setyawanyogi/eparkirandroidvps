import 'package:flutter/cupertino.dart';


class EmailProvider extends ChangeNotifier {
  String _email = "";

  String get getEmail => _email;

  saveEmail(String email) {
    _email = email;
    notifyListeners();
  }
}