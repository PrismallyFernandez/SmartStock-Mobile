import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/product.dart';
import '../providers/product_provider.dart';

/// Formulario para crear o editar un producto (RF-04 / RF-05).
class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key, this.product});

  final Product? product;

  bool get isEditing => product != null;

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _code;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _cost;
  late final TextEditingController _stock;
  late final TextEditingController _threshold;
  late final TextEditingController _category;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _code = TextEditingController(text: p?.code ?? '');
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toStringAsFixed(2) ?? '');
    _cost = TextEditingController(text: p?.cost.toStringAsFixed(2) ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '');
    _threshold = TextEditingController(
      text: p?.lowStockThreshold.toString() ?? '5',
    );
    _category = TextEditingController(text: p?.category ?? '');
  }

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();
    _description.dispose();
    _price.dispose();
    _cost.dispose();
    _stock.dispose();
    _threshold.dispose();
    _category.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider = context.read<ProductProvider>();
    final String? error;

    if (widget.isEditing) {
      error = await provider.edit(
        widget.product!.copyWith(
          code: _code.text.trim(),
          name: _name.text.trim(),
          description: _description.text.trim(),
          price: double.parse(_price.text),
          cost: double.parse(_cost.text),
          stock: int.parse(_stock.text),
          lowStockThreshold: int.parse(_threshold.text),
          category: _category.text.trim(),
        ),
      );
    } else {
      error = await provider.create(
        code: _code.text.trim(),
        name: _name.text.trim(),
        description: _description.text.trim(),
        price: double.parse(_price.text),
        cost: double.parse(_cost.text),
        stock: int.parse(_stock.text),
        lowStockThreshold: int.parse(_threshold.text),
        category: _category.text.trim(),
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);

    if (error == null) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  String? _number(String? v, {bool allowDecimal = true}) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final num? parsed = allowDecimal ? double.tryParse(v) : int.tryParse(v);
    if (parsed == null) return 'Valor numerico invalido';
    if (parsed < 0) return 'No puede ser negativo';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _code,
              decoration: const InputDecoration(
                labelText: 'Codigo unico',
                helperText: 'No puede repetirse con otro producto',
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _category,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Categoria'),
              validator: _required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Descripcion'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _price,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Precio venta'),
                    validator: (v) => _number(v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cost,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(labelText: 'Costo'),
                    validator: (v) => _number(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stock,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Stock actual'),
                    validator: (v) => _number(v, allowDecimal: false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _threshold,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration:
                        const InputDecoration(labelText: 'Alerta bajo stock'),
                    validator: (v) => _number(v, allowDecimal: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Guardar producto'),
            ),
          ],
        ),
      ),
    );
  }
}
