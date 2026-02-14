import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/business_service.dart';
import '../../../shared/models/business.dart';

// Provider for business details
final businessDetailsProvider = FutureProvider.family<Business, int>((ref, businessId) async {
  final businessService = ref.watch(businessServiceProvider);
  return await businessService.getBusinessById(businessId);
});

class BusinessDetailsScreen extends ConsumerWidget {
  final int businessId;
  
  const BusinessDetailsScreen({
    super.key,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessAsync = ref.watch(businessDetailsProvider(businessId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Details'),
      ),
      body: businessAsync.when(
        data: (business) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Business Image/Icon
                Container(
                  height: 200,
                  color: Colors.blue[100],
                  child: Center(
                    child: Icon(
                      Icons.store,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Business Name
                      Text(
                        business.displayName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Distance
                      if (business.distance != null)
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              business.distanceDisplay,
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      
                      // Description
                      if (business.businessDescription != null) ...[
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          business.businessDescription!,
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Contact Info
                      Text(
                        'Contact Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (business.email.isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email'),
                          subtitle: Text(business.email),
                          contentPadding: EdgeInsets.zero,
                        ),
                      if (business.phone != null)
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: const Text('Phone'),
                          subtitle: Text(business.phone!),
                          contentPadding: EdgeInsets.zero,
                        ),
                      const SizedBox(height: 24),
                      
                      // Action: Chat only (no Create Order for now)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.push('/customer/chat/${business.id}');
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('Start Chat'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading business details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString().replaceAll('Exception: ', ''),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(businessDetailsProvider(businessId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
