import 'dart:math';
import 'dart:convert';

class Validations {
  static int passValidation(String pass) {
    int contador = 0;
    if (pass.length >= 8) contador += 10; // 8 characters or more
    if (pass.contains(RegExp(r'[0-9]'))) contador += 10; // contains digit
    if (pass.contains(RegExp(r'[A-Z]'))) contador += 10; // contains upper
    return contador;
  }

  static bool userValidation(String user) {
    bool userValid = false;
    if (user.length <= 45 && user.length >= 2) userValid = true;
    return userValid; // True - OK /// False - Not ok
  }

  static String generateKey([int length = 16]) {
    // Generates secure key to recover pass
    Random _random = Random.secure();
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }

  static String generatePass() {
    String _pass = "";
    final length = 16;
    final lowerCase = 'abcdefghijklmnopqrstuvwxyz';
    final upperCase = lowerCase.toUpperCase();
    final numbers = '0123456789';
    final special = '@=!?';

    _pass += lowerCase + upperCase + numbers + special;

    return List.generate(length, (index) {
      final random = Random.secure().nextInt(_pass.length);

      return _pass[random];
    }).join("");
  }
}
