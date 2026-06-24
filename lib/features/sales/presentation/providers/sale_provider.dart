import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../auth/domain/entities/app_user.dart';
import '../../../clients/domain/entities/client.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/sale_usecases.dart';

/// Resultado de registrar una venta.
class SaleResult {
  const SaleResult({this.error, this.sale});
  final String? error;
  final Sale? sale;
  bool get success => error == null && sale != null;
}

/// Estado del modulo de ventas.
class SaleProvider extends ChangeNotifier {
  SaleProvider({
    required GetSales getSales,
    required RegisterSale registerSale,
  }) : _getSales = getSales,
       _registerSale = registerSale;

  final GetSales _getSales;
  final RegisterSale _registerSale;
  final _uuid = const Uuid();

  List<Sale> _sales = [];
  bool _isLoading = false;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;

  int get totalSales => _sales.length;

  double get totalRevenue =>
      _sales.fold(0, (sum, s) => sum + s.total);

  double get todayRevenue {
    final now = DateTime.now();
    return _sales
        .where((s) =>
            s.date.year == now.year &&
            s.date.month == now.month &&
            s.date.day == now.day)
        .fold(0, (sum, s) => sum + s.total);
  }

  List<Sale> get recentSales => _sales.take(5).toList();

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    _sales = await _getSales();
    _isLoading = false;
    notifyListeners();
  }

  Future<SaleResult> register({
    required List<SaleItem> items,
    required AppUser seller,
    Client? client,
  }) async {
    try {
      final sale = Sale(
        id: _uuid.v4(),
        date: DateTime.now(),
        items: items,
        clientId: client?.id,
        clientName: client?.name ?? 'Cliente general',
        sellerId: seller.id,
        sellerName: seller.name,
      );
      final saved = await _registerSale(sale);
      await load();
      return SaleResult(sale: saved);
    } on BusinessRuleException catch (e) {
      return SaleResult(error: e.message);
    } on NotFoundException catch (e) {
      return SaleResult(error: e.message);
    } catch (_) {
      return const SaleResult(error: 'No se pudo registrar la venta.');
    }
  }
}
