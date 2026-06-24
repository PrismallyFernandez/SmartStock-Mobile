import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/inventory_entry.dart';
import '../../domain/usecases/inventory_usecases.dart';

/// Estado del modulo de inventario.
class InventoryProvider extends ChangeNotifier {
  InventoryProvider({
    required GetInventoryEntries getEntries,
    required RegisterStockEntry registerStockEntry,
    required GetLowStockProducts getLowStockProducts,
  }) : _getEntries = getEntries,
       _registerStockEntry = registerStockEntry,
       _getLowStockProducts = getLowStockProducts;

  final GetInventoryEntries _getEntries;
  final RegisterStockEntry _registerStockEntry;
  final GetLowStockProducts _getLowStockProducts;

  List<InventoryEntry> _entries = [];
  List<Product> _lowStock = [];
  bool _isLoading = false;

  List<InventoryEntry> get entries => _entries;
  List<Product> get lowStock => _lowStock;
  bool get isLoading => _isLoading;
  int get lowStockCount => _lowStock.length;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _entries = await _getEntries();
    _lowStock = await _getLowStockProducts();
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> registerEntry({
    required String productId,
    required int quantity,
    required String note,
  }) async {
    try {
      await _registerStockEntry(
        productId: productId,
        quantity: quantity,
        note: note,
      );
      await load();
      return null;
    } on BusinessRuleException catch (e) {
      return e.message;
    } catch (_) {
      return 'No se pudo registrar la entrada.';
    }
  }
}
