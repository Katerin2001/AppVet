import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';


class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  final UrlError = 'https://firebasestorage.googleapis.com/v0/b/veterinariaapp-3cc9c.appspot.com/o/5220262.png?alt=media&token=494838bf-6cb4-479e-ae7f-e9edd35037dc';

  Future<List<Map<String, dynamic>>?> searchProducts(String keyword, String type) async {
  try {
    // Realizar una consulta para buscar productos que coincidan con el nombre y tipo
    QuerySnapshot querySnapshot;

    if (keyword.isNotEmpty) {
      // Si la palabra clave no está vacía, buscar coincidencias exactas
      querySnapshot = await _firestore
          .collection('Elemento')
          .where('Nombre', isEqualTo: keyword)
          .where('Tipo', isEqualTo: type)
          .get();
    } else {
      // Si la palabra clave está vacía, buscar solo por tipo
      querySnapshot = await _firestore
          .collection('Elemento')
          .where('Tipo', isEqualTo: type)
          .get();
    }

    // Verificar si hay resultados en la consulta
    if (querySnapshot.docs.isNotEmpty) {
      // Mapear los resultados a una lista de mapas con el ID único incluido
      List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(
        querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Agregar el ID único al mapa
          return data;
        }),
      );
      return products;
    } else {
      // Si no hay resultados, retornar una lista vacía
      return [];
    }
  } catch (e) {
    print("Error al buscar productos: $e");
    return null;
  }
}


  
  Future<void> agregarProducto(String nombre, String tipo, String precio, File imagen) async {
    try {
      
      
        // Subir la imagen a Firebase Storage y agregar el producto
        String imageUrl = await _subirImagenAStorage(imagen);
        await _firestore.collection('Elemento').add({
          'Nombre': nombre,
          'Tipo': tipo,
          'Precio': precio,
          'ZImage': imageUrl,
        });
      

      print('Producto agregado con éxito a Firebase.');
    } catch (e) {
      print('Error al agregar el producto a Firebase: $e');
    }
  }

  Future<String> _subirImagenAStorage(File imagen) async {
    try {
      // Generar un nombre único para la imagen
      String imageName = DateTime.now().millisecondsSinceEpoch.toString();

      // Crear una referencia al lugar donde se almacenará la imagen en Storage
      Reference ref = _storage.ref().child(imageName);

      // Subir la imagen a Storage
      UploadTask uploadTask = ref.putFile(imagen);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      // Obtener la URL de la imagen después de subirla con éxito
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Error al subir la imagen a Firebase Storage: $e');
      return '';
    }
  }

  Future<void> eliminarProducto(String id) async {
    try {
      //Dado el Id obtneemos el producto
      DocumentSnapshot documentSnapshot = await _firestore.collection('Elemento').doc(id).get();

      //Convertimso la respuesta en un mapa
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

      //Obtenemos la URL de la imagen

      String imageUrl = data['ZImage'];

      //Eliminar el producto de Firestore
      await _firestore.collection('Elemento').doc(id).delete();

      //Eliminar la imagen de Firebase Storage

      if (imageUrl != UrlError ){
        await _storage.refFromURL(imageUrl).delete();
      }

      print('Producto eliminado con éxito de Firebase.');
    } catch (e) {
      print('Error al eliminar el producto de Firebase: $e');
    }
  }

  //Funcion para editar productos Recibe , nombre , precio y tipo y el id (No recbe la imagen)
  Future<void> editarProducto(String nombre, String tipo, String precio, String id) async {
    try {
      print(id);
      //Obtenemos el producto de Firestore
      DocumentSnapshot documentSnapshot = await _firestore.collection('Elemento').doc(id).get();

      //Convertimos la respuesta en un mapa
      Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

      //Obtenemos la URL de la imagen
      String imageUrl = data['ZImage'];

      print('URL de la imagen: $imageUrl');
      //Actualizar el producto en Firestore
      await _firestore.collection('Elemento').doc(id).update({
        'Nombre': nombre,
        'Tipo': tipo,
        'Precio': precio,
        'ZImage': imageUrl
      });

      print('Producto editado con éxito en Firebase.');
    } catch (e) {
      print('Error al editar el producto en Firebase: $e');
    }
  }
  
}
