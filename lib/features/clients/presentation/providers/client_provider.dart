import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/client.dart';
import '../../domain/usecases/client_usecases.dart';

/// Estado del modulo de clientes.
class ClientProvider extends ChangeNotifier {
  ClientProvider({
    required GetClients getClients,
    required AddClient addClient,
    required UpdateClient updateClient,
    required DeleteClient deleteClient,
  }) : _getClients = getClients,
       _addClient = addClient,
       _updateClient = updateClient,
       _deleteClient = deleteClient;

  final GetClients _getClients;
  final AddClient _addClient;
  final UpdateClient _updateClient;
  final DeleteClient _deleteClient;
  final _uuid = const Uuid();

  List<Client> _clients = [];
  bool _isLoading = false;

  List<Client> get clients => _clients;
  bool get isLoading => _isLoading;
  int get totalClients => _clients.length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _clients = await _getClients();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> create({
    required String name,
    required String phone,
    required String email,
    required String address,
  }) async {
    await _addClient(Client(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      address: address,
    ));
    await load();
  }

  Future<void> edit(Client client) async {
    await _updateClient(client);
    await load();
  }

  Future<void> remove(String id) async {
    await _deleteClient(id);
    await load();
  }
}
