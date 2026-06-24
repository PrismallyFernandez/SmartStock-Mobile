// Pruebas unitarias de las reglas de negocio clave, contra un Firestore falso.

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartstock_mobile/core/constants/firestore_collections.dart';
import 'package:smartstock_mobile/core/error/exceptions.dart';
import 'package:smartstock_mobile/features/products/data/datasources/product_remote_data_source.dart';
import 'package:smartstock_mobile/features/products/domain/entities/product.dart';
import 'package:smartstock_mobile/features/sales/data/datasources/sale_remote_data_source.dart';
import 'package:smartstock_mobile/features/sales/domain/entities/sale.dart';

Future<void> _seedProduct(
  FakeFirebaseFirestore db, {
  required String id,
  required String code,
  required int stock,
}) {
  return db.collection(FirestoreCollections.products).doc(id).set({
    'code': code,
    'name': 'Producto $id',
    'description': '',
    'price': 100,
    'cost': 50,
    'stock': stock,
    'lowStockThreshold': 2,
    'category': 'Prueba',
  });
}

void main() {
  late FakeFirebaseFirestore db;
  late ProductRemoteDataSourceImpl productDs;
  late SaleRemoteDataSourceImpl saleDs;

  setUp(() {
    db = FakeFirebaseFirestore();
    productDs = ProductRemoteDataSourceImpl(db);
    saleDs = SaleRemoteDataSourceImpl(db);
  });

  test('No permite dos productos con el mismo codigo (codigo unico)', () async {
    await _seedProduct(db, id: 'p1', code: 'DUP-1', stock: 10);

    expect(
      () => productDs.addProduct(
        const Product(
          id: 'p2',
          code: 'DUP-1',
          name: 'Otro',
          description: '',
          price: 1,
          cost: 1,
          stock: 1,
          lowStockThreshold: 1,
          category: 'Prueba',
        ),
      ),
      throwsA(isA<BusinessRuleException>()),
    );
  });

  test('No permite vender con stock insuficiente', () async {
    await _seedProduct(db, id: 'p1', code: 'STK-1', stock: 3);

    final sale = Sale(
      id: 'ignored',
      date: DateTime.now(),
      items: const [
        SaleItem(
          productId: 'p1',
          productName: 'Producto p1',
          unitPrice: 100,
          quantity: 10,
        ),
      ],
      clientId: null,
      clientName: 'Cliente general',
      sellerId: 'u1',
      sellerName: 'Tester',
    );

    expect(
      () => saleDs.registerSale(sale),
      throwsA(isA<BusinessRuleException>()),
    );
  });

  test('La venta descuenta el stock automaticamente', () async {
    await _seedProduct(db, id: 'p1', code: 'STK-2', stock: 10);

    final sale = Sale(
      id: 'ignored',
      date: DateTime.now(),
      items: const [
        SaleItem(
          productId: 'p1',
          productName: 'Producto p1',
          unitPrice: 100,
          quantity: 3,
        ),
      ],
      clientId: null,
      clientName: 'Cliente general',
      sellerId: 'u1',
      sellerName: 'Tester',
    );

    await saleDs.registerSale(sale);

    final doc =
        await db.collection(FirestoreCollections.products).doc('p1').get();
    expect(doc.data()!['stock'], 7);

    // Se registro el movimiento de inventario por la venta.
    final entries =
        await db.collection(FirestoreCollections.inventoryEntries).get();
    expect(entries.docs.length, 1);
    expect(entries.docs.first.data()['type'], 'venta');
  });

  test('Se puede registrar y luego leer un producto', () async {
    await productDs.addProduct(
      const Product(
        id: 'new-1',
        code: 'NEW-1',
        name: 'Nuevo',
        description: 'desc',
        price: 200,
        cost: 120,
        stock: 5,
        lowStockThreshold: 2,
        category: 'General',
      ),
    );

    final products = await productDs.getProducts();
    expect(products.any((p) => p.code == 'NEW-1'), isTrue);

    // Verifica el tipo concreto del campo persistido.
    final doc = await db.collection(FirestoreCollections.products).doc('new-1').get();
    expect(doc.data()!['price'], isA<num>());
    expect((doc.data() as Map<String, dynamic>).containsKey('id'), isTrue);
  });
}
