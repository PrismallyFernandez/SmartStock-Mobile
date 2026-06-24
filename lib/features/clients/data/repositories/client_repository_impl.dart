import '../../domain/entities/client.dart';
import '../../domain/repositories/client_repository.dart';
import '../datasources/client_remote_data_source.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl(this._dataSource);

  final ClientRemoteDataSource _dataSource;

  @override
  Future<List<Client>> getClients() => _dataSource.getClients();

  @override
  Future<Client> addClient(Client client) => _dataSource.addClient(client);

  @override
  Future<Client> updateClient(Client client) =>
      _dataSource.updateClient(client);

  @override
  Future<void> deleteClient(String id) => _dataSource.deleteClient(id);
}
