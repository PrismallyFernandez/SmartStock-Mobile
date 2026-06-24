import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Servicio de almacenamiento de archivos sobre Firebase Storage.
///
/// Preparado para subir imagenes de productos en versiones futuras. Hoy no se
/// usa en la UI, pero deja la integracion lista.
class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;

  /// Sube un archivo y devuelve su URL de descarga.
  Future<String> uploadFile(String path, File file) async {
    final ref = _storage.ref(path);
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Sube la imagen de un producto y devuelve su URL.
  Future<String> uploadProductImage(String productId, File image) {
    return uploadFile('products/$productId.jpg', image);
  }

  Future<void> delete(String path) => _storage.ref(path).delete();
}
