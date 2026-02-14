import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/services/order_service.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/order_item.dart';

final _orderDetailProvider = FutureProvider.family<Order, int>((ref, id) async {
  return ref.read(orderServiceProvider).getOrder(id);
});

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  bool _confirming = false;
  bool _paying = false;

  Future<void> _confirm() async {
    setState(() => _confirming = true);
    try {
      await ref.read(orderServiceProvider).confirmOrder(widget.orderId);
      ref.invalidate(_orderDetailProvider(widget.orderId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order confirmed. Please complete payment.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      await ref.read(orderServiceProvider).confirmPayment(widget.orderId);
      ref.invalidate(_orderDetailProvider(widget.orderId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful (mock)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(_orderDetailProvider(widget.orderId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(_orderDetailProvider(widget.orderId)),
          ),
        ],
      ),
      body: async.when(
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _section('Status', order.statusDisplay),
                _section('Business', order.businessName ?? '—'),
                _section('Delivery', order.deliveryAddress),
                if (order.riderId != null && (order.riderName != null || order.riderPhone != null)) ...[
                  const SizedBox(height: 8),
                  _riderSection(order),
                ],
                const SizedBox(height: 16),
                Text(
                  'Items',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (order.items.isEmpty)
                  Text(
                    'No items yet. Business will add items.',
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
                const SizedBox(height: 24),
                if (order.isNegotiating) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirming ? null : _confirm,
                      child: _confirming
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Confirm order'),
                    ),
                  ),
                ],
                if (order.isAwaitingPayment) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _paying ? null : _pay,
                      child: _paying
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Pay (mock UPI)'),
                    ),
                  ),
                ],
                if ((order.isRiderAssigned || order.isInTransit) &&
                    order.totalAmount != null &&
                    AppConfig.upiVpa.isNotEmpty &&
                    !AppConfig.upiVpa.startsWith('YOUR_')) ...[
                  const SizedBox(height: 24),
                  _payOnDeliverySection(order),
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
                onPressed: () => ref.invalidate(_orderDetailProvider(widget.orderId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _payOnDeliverySection(Order order) {
    final amount = order.totalAmount!;
    final vpa = AppConfig.upiVpa;
    final name = AppConfig.upiPayeeName;
    final upiString =
        'upi://pay?pa=${Uri.encodeComponent(vpa)}&pn=${Uri.encodeComponent(name)}&am=${amount.toStringAsFixed(2)}&cu=INR';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_2, size: 24, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              'Pay on delivery',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Scan QR to pay ₹${amount.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: QrImageView(
                data: upiString,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Or pay to $vpa',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _riderSection(Order order) {
    final name = order.riderName ?? 'Rider';
    final phone = order.riderPhone;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.two_wheeler, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Your rider',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            if (phone != null && phone.isNotEmpty) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () async {
                  final uri = Uri.parse('tel:$phone');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.phone, size: 18, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 6),
                    Text(phone, style: TextStyle(fontSize: 15, color: Theme.of(context).primaryColor)),
                  ],
                ),
              ),
            ],
          ],
        ),
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
}
