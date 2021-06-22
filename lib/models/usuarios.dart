class Usuarios // *******Change class if BD is changed*******
{
  // Clase con la forma de usuario
  final String usuario;
  final String pass;
  final String key;

  Usuarios({required this.usuario, required this.pass, required this.key});

  Map<String, dynamic> toMap() {
    // Used to retrieve from database
    return {
      'usuario': usuario,
      'pass': pass,
      'key': key,
    };
  }

  // No explanation needed

  String getusuario() {
    return usuario;
  }

  String getpassword() {
    return pass;
  }

  String getkey() {
    return key;
  }
}
