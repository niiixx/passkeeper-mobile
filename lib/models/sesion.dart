class Sesion {
  // This class will keep during the execution of the application
  // the credentials of the user logged in
  static String _usuario = "";
  static String _pass = "";
  static String _key = "";

  // No explanation needed
  static changeUsuario(String usuario) {
    _usuario = usuario;
  }

  static changePass(String pass) {
    _pass = pass;
  }

  static changeKey(String key) {
    _key = key;
  }

  static restart() {
    changeKey("");
    changePass("");
    changeUsuario("");
  }

  static printUsuario() {
    print(_usuario);
  }

  static printPass() {
    print(_pass);
  }

  static printKey() {
    print(_key);
  }

  static getUsuario() {
    return _usuario;
  }

  static getPass() {
    return _pass;
  }

  static getKey() {
    return _key;
  }
} // Sesion actual
