import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, String>?> signInWithCredentials(
      String username, String password) async {
    try {
      
      //print("Username : "+ username + "\nPassword : " + password);
      QuerySnapshot querySnapshot = await _firestore
          .collection('Persona')
          .where('User', isEqualTo: username)
          .where('Password', isEqualTo: password)
          .limit(1)
          .get();

      // Si hay un documento en la consulta, las credenciales son válidas
      if (querySnapshot.docs.isNotEmpty) {
        final user = querySnapshot.docs.first;
        final nombre = user['Nombre'] as String;
        final tipo = user['Tipe'] as String;
        return {'nombre': nombre, 'tipo': tipo};
      } else {
        
        return null;
      }
    } catch (e) {
      print("Error al validar credenciales: $e");
      return null;
    }
  }

  
  //Funcion para registrar un usuario Recibe Nombre, User y Password
  Future<void> registrarUsuario(String nombre, String user, String password) async {
    try {
      // Agregar el usuario a la colección de usuarios
      await _firestore.collection('Persona').add({
        'Nombre': nombre,
        'User': user,
        'Password': password,
        'Tipe': 'Usuario',
      });
    } catch (e) {
      print("Error al registrar usuario: $e");
    }
  }
  
}


