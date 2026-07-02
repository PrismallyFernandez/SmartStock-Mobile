import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../storage/storage_service.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/login_user.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

// Products
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/usecases/product_usecases.dart';
import '../../features/products/presentation/providers/product_provider.dart';

// Clients
import '../../features/clients/data/datasources/client_remote_data_source.dart';
import '../../features/clients/data/repositories/client_repository_impl.dart';
import '../../features/clients/domain/usecases/client_usecases.dart';
import '../../features/clients/presentation/providers/client_provider.dart';

// Sales
import '../../features/sales/data/datasources/sale_remote_data_source.dart';
import '../../features/sales/data/repositories/sale_repository_impl.dart';
import '../../features/sales/domain/usecases/sale_usecases.dart';
import '../../features/sales/presentation/providers/sale_provider.dart';

// Categories
import '../../features/categories/data/datasources/category_remote_data_source.dart';
import '../../features/categories/data/repositories/category_repository_impl.dart';
import '../../features/categories/domain/usecases/category_usecases.dart';
import '../../features/categories/presentation/providers/category_provider.dart';

// Inventory
import '../../features/inventory/data/datasources/inventory_remote_data_source.dart';
import '../../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../../features/inventory/domain/usecases/inventory_usecases.dart';
import '../../features/inventory/presentation/providers/inventory_provider.dart';

/// Composicion de dependencias (manual). Construye la cadena
/// data source (Firebase) -> repositorio -> casos de uso -> provider.
class ServiceLocator {
  ServiceLocator._();

  /// Servicio de Storage disponible para inyectar donde se necesite (futuro).
  static final StorageService storage =
      StorageService(FirebaseStorage.instance);

  static List<SingleChildWidget> providers() {
    final firestore = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;

    // --- Repositorios (cada uno con su data source de Firebase) ---
    final authRepository = AuthRepositoryImpl(
      AuthRemoteDataSourceImpl(auth: auth, firestore: firestore),
    );
    final productRepository =
        ProductRepositoryImpl(ProductRemoteDataSourceImpl(firestore));
    final clientRepository =
        ClientRepositoryImpl(ClientRemoteDataSourceImpl(firestore));
    final saleRepository =
        SaleRepositoryImpl(SaleRemoteDataSourceImpl(firestore));
    final categoryRepository =
        CategoryRepositoryImpl(CategoryRemoteDataSourceImpl(firestore));
    final inventoryRepository =
        InventoryRepositoryImpl(InventoryRemoteDataSourceImpl(firestore));

    return [
      ChangeNotifierProvider(
        create: (_) => AuthProvider(
          loginUser: LoginUser(authRepository),
          repository: authRepository,
        )..checkSession(),
      ),
      ChangeNotifierProvider(
        create: (_) => ProductProvider(
          getProducts: GetProducts(productRepository),
          addProduct: AddProduct(productRepository),
          updateProduct: UpdateProduct(productRepository),
          deleteProduct: DeleteProduct(productRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ClientProvider(
          getClients: GetClients(clientRepository),
          addClient: AddClient(clientRepository),
          updateClient: UpdateClient(clientRepository),
          deleteClient: DeleteClient(clientRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => SaleProvider(
          getSales: GetSales(saleRepository),
          registerSale: RegisterSale(saleRepository),
          updateSale: UpdateSale(saleRepository),
          deleteSale: DeleteSale(saleRepository),
          getSalesByDateRange: GetSalesByDateRange(saleRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => CategoryProvider(
          getCategories: GetCategories(categoryRepository),
          addCategory: AddCategory(categoryRepository),
          updateCategory: UpdateCategory(categoryRepository),
          deleteCategory: DeleteCategory(categoryRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => InventoryProvider(
          getEntries: GetInventoryEntries(inventoryRepository),
          registerStockEntry: RegisterStockEntry(inventoryRepository),
          getLowStockProducts: GetLowStockProducts(inventoryRepository),
        ),
      ),
    ];
  }
}
