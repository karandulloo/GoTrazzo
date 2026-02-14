import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/rider_service.dart';
import '../../../core/utils/token_storage.dart';
import '../../../shared/models/order.dart';

final _riderOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final uid = await TokenStorage.getUserId();
  if (uid == null) return [];
  return ref.read(orderServiceProvider).getRiderOrders(uid);
});

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  String _status = 'OFFLINE'; // AVAILABLE, BUSY, OFFLINE
  bool _statusLoading = false;

  Future<void> _setStatus(String s) async {
    final uid = await TokenStorage.getUserId();
    if (uid == null) return;
    setState(() => _statusLoading = true);
    try {
      await ref.read(riderServiceProvider).updateStatus(uid, s);
      setState(() {
        _status = s;
        _statusLoading = false;
      });
      ref.invalidate(_riderOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status: $s')),
        );
      }
    } catch (e) {
      setState(() => _statusLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _acceptOrder(Order o) async {
    try {
      await ref.read(orderServiceProvider).riderAcceptOrder(o.id);
      ref.invalidate(_riderOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery started')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _markDelivered(Order o) async {
    try {
      await ref.read(orderServiceProvider).riderMarkDelivered(o.id);
      ref.invalidate(_riderOrdersProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Delivery completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _statusChip('AVAILABLE', Icons.check_circle),
                        const SizedBox(width: 8),
                        _statusChip('BUSY', Icons.hourglass_empty),
                        const SizedBox(width: 8),
                        _statusChip('OFFLINE', Icons.cancel),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'My orders',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ref.watch(_riderOrdersProvider).when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                Text(
                                  'No assigned orders',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: orders.map((o) => _orderCard(o)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('Error: ${e.toString().replaceAll('Exception: ', '')}', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(_riderOrdersProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String s, IconData icon) {
    final active = _status == s;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: active ? Colors.white : null),
          const SizedBox(width: 6),
          Text(s == 'AVAILABLE' ? 'Available' : s == 'BUSY' ? 'Busy' : 'Offline'),
        ],
      ),
      selected: active,
      onSelected: _statusLoading
          ? null
          : (v) {
              if (v) _setStatus(s);
            },
    );
  }

  Widget _orderCard(Order o) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Order #${o.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(o.statusDisplay, style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Deliver to: ${o.deliveryAddress}', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
            const SizedBox(height: 12),
            if (o.isRiderAssigned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _acceptOrder(o),
                  icon: const Icon(Icons.directions_bike),
                  label: const Text('Start delivery'),
                ),
              ),
            if (o.isInTransit)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _markDelivered(o),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark delivered'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
