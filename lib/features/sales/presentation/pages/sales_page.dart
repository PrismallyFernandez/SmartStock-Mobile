import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/sale.dart';
import '../providers/sale_provider.dart';
import 'new_sale_page.dart';
import 'sale_receipt_sheet.dart';

/// Historial de ventas (RF-16) y acceso a registrar una nueva venta.
class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().load();
    });
  }

  Future<void> _newSale() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NewSalePage()),
    );
    if (mounted) context.read<SaleProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ventas')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'sales_fab',
        onPressed: _newSale,
        icon: const Icon(Icons.add_shopping_cart_rounded),
        label: const Text('Vender'),
      ),
      body: Consumer<SaleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.sales.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.sales.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Sin ventas',
              message: 'Las ventas registradas apareceran aqui.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: provider.sales.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final sale = provider.sales[index];
              return _SaleCard(
                sale: sale,
                onTap: () => showSaleReceipt(context, sale),
              );
            },
          );
        },
      ),
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale, required this.onTap});

  final Sale sale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.receipt_long_rounded,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sale.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.dateTime(sale.date)}  ·  ${sale.totalUnits} und.',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.currency(sale.total),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
