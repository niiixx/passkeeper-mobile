class Cuentas {
  // Clase con los datos de cuentas
  final String owner;
  final String user;
  final String pass;
  final String sitio;

  Cuentas(
      {required this.owner,
      required this.user,
      required this.pass,
      required this.sitio});

  Map<String, dynamic> toMap() {
    // Used to retrieve from database
    return {
      'owner': owner,
      'sitio': sitio,
      'usuario': user,
      'pass': pass,
    };
  }

  // No explanation needed

  String getowner() {
    return owner;
  }

  String getuser() {
    return user;
  }

  String getpass() {
    return pass;
  }

  String getsitio() {
    return sitio;
  }
}
