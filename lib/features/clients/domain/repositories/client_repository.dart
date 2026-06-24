import '../entities/client.dart';

/// Contrato de gestion de clientes (RF-05 del modulo de clientes).
abstract class ClientRepository {
  Future<List<Client>> getClients();
  Future<Client> addClient(Client client);
  Future<Client> updateClient(Client client);
  Future<void> deleteClient(String id);
}
