import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../domain/entities/client.dart';
import '../models/client_model.dart';

/// Fuente de datos de clientes sobre Cloud Firestore (coleccion `clients`).
abstract class ClientRemoteDataSource {
  Future<List<Client>> getClients();
  Future<Client> addClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String id);
}

class ClientRemoteDataSourceImpl implements ClientRemoteDataSource {
  ClientRemoteDataSourceImpl(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(FirestoreCollections.clients);

  @override
  Future<List<Client>> getClients() async {
    final snap = await _col.orderBy('name').get();
    return snap.docs
        .map((d) => ClientModel.fromMap({'id': d.id, ...d.data()}))
        .toList();
  }

  @override
  Future<Client> addClient(Client client) async {
    await _col.doc(client.id).set(ClientModel.fromEntity(client).toMap());
    return client;
  }

  @override
  Future<Client> updateClient(Client client) async {
    await _col.doc(client.id).set(ClientModel.fromEntity(client).toMap());
    return client;
  }

  @override
  Future<void> deleteClient(String id) => _col.doc(id).delete();
}
