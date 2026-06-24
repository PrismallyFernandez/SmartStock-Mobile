import '../entities/client.dart';
import '../repositories/client_repository.dart';

/// Casos de uso del modulo de clientes.

class GetClients {
  GetClients(this._repo);
  final ClientRepository _repo;
  Future<List<Client>> call() => _repo.getClients();
}

class AddClient {
  AddClient(this._repo);
  final ClientRepository _repo;
  Future<Client> call(Client client) => _repo.addClient(client);
}

class UpdateClient {
  UpdateClient(this._repo);
  final ClientRepository _repo;
  Future<Client> call(Client client) => _repo.updateClient(client);
}

class DeleteClient {
  DeleteClient(this._repo);
  final ClientRepository _repo;
  Future<void> call(String id) => _repo.deleteClient(id);
}
