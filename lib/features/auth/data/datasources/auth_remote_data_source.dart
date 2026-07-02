import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_user.dart';
import '../models/user_model.dart';

/// Fuente de datos de autenticacion sobre Firebase.
///
/// Autentica con Firebase Authentication (correo/contrasena) y obtiene el
/// perfil y el rol del usuario desde la coleccion `users` de Firestore.
abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> currentUser();
  Future<List<UserModel>> getUsers();
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      return _profile(uid, credential.user!.email ?? email.trim());
    } on FirebaseAuthException catch (e) {
      throw InvalidCredentialsException(_mapAuthError(e));
    }
  }

  @override
  Future<UserModel?> currentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _profile(user.uid, user.email ?? '');
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<List<UserModel>> getUsers() async {
    final snap = await _firestore
        .collection(FirestoreCollections.users)
        .orderBy('name')
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      return UserModel.fromMap({'id': d.id, ...data});
    }).toList();
  }

  @override
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = credential.user!.uid;
      await _firestore.collection(FirestoreCollections.users).doc(uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'role': role.name,
      });
      // Cerrar sesion del nuevo usuario para no desplazar al administrador.
      await _auth.signOut();
      return UserModel(
        id: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
      );
    } on FirebaseAuthException catch (e) {
      throw InvalidCredentialsException(_mapAuthError(e));
    }
  }

  /// Lee el documento `users/{uid}` con el nombre y rol del usuario.
  Future<UserModel> _profile(String uid, String email) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    if (!doc.exists) {
      throw InvalidCredentialsException(
        'Tu cuenta no tiene un perfil asignado. Contacta al administrador.',
      );
    }
    return UserModel.fromMap({'id': uid, 'email': email, ...doc.data()!});
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correo no es valido.';
      case 'user-disabled':
        return 'Esta cuenta esta deshabilitada.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contrasena incorrectos.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta mas tarde.';
      case 'network-request-failed':
        return 'Sin conexion. Verifica tu internet.';
      default:
        return 'No se pudo iniciar sesion (${e.code}).';
    }
  }
}
