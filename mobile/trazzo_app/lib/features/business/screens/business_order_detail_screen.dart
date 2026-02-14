import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_item.dart';

final _businessOrderDetailProvider = FutureProvider.family<Order, int>((ref, id) async {
  return ref.read(orderServiceProvider).getOrder(id);
});

class BusinessOrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;

  const BusinessOrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<BusinessOrderDetailScreen> createState() => _BusinessOrderDetailScreenState();
}

class _BusinessOrderDetailScreenState extends ConsumerState<BusinessOrderDetailScreen> {
  final _items = <_ItemForm>[];
  bool _loading = false;
  bool _editing = false;

  void _addItem() {
    setState(() => _items.add(_ItemForm(name: '', qty: 1, price: 0, notes: '')));
  }

  void _removeItem(int i) {
    setState(() {
      _items.removeAt(i);
      if (_items.isEmpty) _items.add(_ItemForm(name: '', qty: 1, price: 0, notes: ''));
    });
  }

  Future<void> _saveItems() async {
    final valid = _items
        .where((e) => e.name.trim().isNotEmpty && e.price >= 0 && e.qty > 0)
        .map((e) => OrderItem(
              itemName: e.name.trim(),
              quantity: e.qty,
              unitPrice: e.price,
              subtotal: e.price * e.qty,
              notes: e.notes.isEmpty ? null : e.notes,
            ))
        .toList();
    if (valid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one item with name, quantity, and price')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(orderServiceProvider).updateOrderItems(widget.orderId, valid);
      ref.invalidate(_businessOrderDetailProvider(widget.orderId));
      setState(() {
        _loading = false;
        _editing = false;
        _items.clear();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Items updated')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_businessOrderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order details'),
      ),
      body: async.when(
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _line('Status', order.statusDisplay),
                _line('Customer', order.customerName ?? '—'),
                _line('Delivery', order.deliveryAddress),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (order.isDraft || order.isNegotiating)
                      TextButton.icon(
                        onPressed: _loading
                            ? null
                            : () {
                                setState(() {
                                  _editing = !_editing;
                                  _items.clear();
                                  if (_editing) {
                                    _items.addAll(
                                      order.items.map((i) => _ItemForm(
                                            name: i.itemName,
                                            qty: i.quantity,
                                            price: i.unitPrice,
                                            notes: i.notes ?? '',
                                          )),
                                    );
                                    if (_items.isEmpty) {
                                      _items.add(_ItemForm(name: '', qty: 1, price: 0, notes: ''));
                                    }
                                  }
                                });
                              },
                        icon: Icon(_editing ? Icons.close : Icons.edit, size: 18),
                        label: Text(_editing ? 'Cancel' : 'Edit items'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_editing) ...[
                  ...List.generate(_items.length, (i) => _itemEditor(i)),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _saveItems,
                      child: _loading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save items'),
                    ),
                  ),
                ] else ...[
                  if (order.items.isEmpty)
                    Text(
                      'No items. Tap "Edit items" to add.',
                      style: TextStyle(color: Colors.grey[600]),
                    )
                  else
                    ...order.items.map((i) => _itemRow(i)),
                  if (order.totalAmount != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Total: ₹${order.totalAmount!.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: ${e.toString().replaceAll('Exception: ', '')}', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_businessOrderDetailProvider(widget.orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _itemRow(OrderItem i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(i.itemName, style: const TextStyle(fontWeight: FontWeight.w500)),
                if (i.notes != null && i.notes!.isNotEmpty)
                  Text(i.notes!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Text('${i.quantity} × ₹${i.unitPrice.toStringAsFixed(2)} = ₹${i.subtotal.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _itemEditor(int index) {
    final f = _items[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: f.name,
                    decoration: const InputDecoration(
                      labelText: 'Item name',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) => f.name = v,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: '${f.qty}',
                    decoration: const InputDecoration(
                      labelText: 'Qty',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => f.qty = int.tryParse(v) ?? 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: f.price > 0 ? '${f.price}' : '',
                    decoration: const InputDecoration(
                      labelText: 'Unit price (₹)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => f.price = double.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: f.notes,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => f.notes = v,
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemForm {
  String name;
  int qty;
  double price;
  String notes;
  _ItemForm({required this.name, required this.qty, required this.price, required this.notes});
}
