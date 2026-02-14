import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/token_storage.dart';
import 'business_details_screen.dart';

class OrderCreateScreen extends ConsumerStatefulWidget {
  final int businessId;

  const OrderCreateScreen({super.key, required this.businessId});

  @override
  ConsumerState<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends ConsumerState<OrderCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  bool _loading = false;
  bool _locationLoading = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locationLoading = true);
    try {
      final loc = await LocationService().getCurrentLocation();
      setState(() {
        _latitude = loc['latitude'];
        _longitude = loc['longitude'];
        _locationLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location updated')),
        );
      }
    } catch (e) {
      setState(() => _locationLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location error: $e')),
        );
      }
    }
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter delivery address')),
      );
      return;
    }
    final lat = _latitude ?? 12.9716;
    final lng = _longitude ?? 77.5946;

    final userId = await TokenStorage.getUserId();
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in again')),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final chatService = ref.read(chatServiceProvider);
      final chat = await chatService.createChat(
        customerId: userId,
        businessId: widget.businessId,
      );

      final orderService = ref.read(orderServiceProvider);
      await orderService.createOrder(
        customerId: userId,
        businessId: widget.businessId,
        chatId: chat.id,
        deliveryAddress: address,
        latitude: lat,
        longitude: lng,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order created')),
      );
      context.go('/customer/orders');
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(businessDetailsProvider(widget.businessId));

    return Scaffold(
      appBar: AppBar(
        title: businessAsync.when(
          data: (b) => Text('Create order · ${b.displayName}'),
          loading: () => const Text('Create order'),
          error: (_, __) => const Text('Create order'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Delivery address',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  hintText: 'e.g. 123 Main St, Bangalore',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _locationLoading ? null : _useCurrentLocation,
                icon: _locationLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_locationLoading
                    ? 'Getting location...'
                    : 'Use current location'),
              ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Location: ${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _createOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
