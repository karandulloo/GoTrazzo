import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/models/business.dart';
import '../providers.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen> {
  String? _selectedCategory;
  
  // Common business categories
  final List<String> _categories = [
    'All',
    'Hardware',
    'Groceries',
    'Restaurant',
    'Pharmacy',
    'Electronics',
    'Clothing',
    'Other',
  ];

  List<Business> _filterBusinessesByCategory(List<Business> businesses) {
    if (_selectedCategory == null || _selectedCategory == 'All') {
      return businesses;
    }
    return businesses.where((business) => 
      business.category?.toLowerCase() == _selectedCategory?.toLowerCase()
    ).toList();
  }

  Map<String, List<Business>> _groupByCategory(List<Business> businesses) {
    final Map<String, List<Business>> grouped = {};
    
    for (var business in businesses) {
      final category = business.category ?? 'Other';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(business);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final locationAsync = ref.watch(customerSearchLocationProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Businesses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            tooltip: 'My address',
            onPressed: () => context.push('/customer/address'),
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () => context.push('/customer/orders'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: locationAsync.when(
        data: (location) {
          // Create stable key from location to prevent infinite provider recreation
          final locationKey = '${location['latitude']}_${location['longitude']}';
          final businessesAsync = ref.watch(
            nearbyBusinessesProvider(locationKey),
          );
          
          // Add timeout handling
          return businessesAsync.when(
            data: (businesses) {
              final filteredBusinesses = _filterBusinessesByCategory(businesses);
              final groupedBusinesses = _groupByCategory(filteredBusinesses);
              
              if (filteredBusinesses.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No businesses found nearby',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try selecting a different category',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  // Category filter chips
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category || 
                          (_selectedCategory == null && category == 'All');
                        
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = selected ? category : null;
                              });
                            },
                            selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                            checkmarkColor: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  
                  // Business list grouped by category
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(customerSearchLocationProvider);
                        final location = ref.read(customerSearchLocationProvider).value;
                        if (location != null) {
                          final locationKey = '${location['latitude']}_${location['longitude']}';
                          ref.invalidate(nearbyBusinessesProvider(locationKey));
                        }
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: groupedBusinesses.length,
                        itemBuilder: (context, index) {
                          final category = groupedBusinesses.keys.elementAt(index);
                          final categoryBusinesses = groupedBusinesses[category]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _getCategoryIcon(category),
                                      size: 20,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${categoryBusinesses.length}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Businesses in this category
                              ...categoryBusinesses.map((business) => Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                    child: Icon(
                                      _getCategoryIcon(business.category ?? 'Other'),
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  title: Text(
                                    business.displayName,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (business.businessDescription != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text(
                                            business.businessDescription!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          if (business.distance != null) ...[
                                            Icon(
                                              Icons.location_on,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              business.distanceDisplay,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    context.push('/customer/business/${business.id}');
                                  },
                                ),
                              )),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading businesses...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      // Cancel - invalidate location to trigger rebuild
                      ref.invalidate(currentLocationProvider);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
            error: (error, stack) {
              // Show detailed error with troubleshooting
              final errorMessage = error.toString().replaceAll('Exception: ', '');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading businesses',
                        style: Theme.of(context).textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Retry - invalidate location to trigger rebuild
                          ref.invalidate(currentLocationProvider);
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                      const SizedBox(height: 12),
                      if (errorMessage.contains('timeout') || errorMessage.contains('connection'))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Tip: Make sure your backend is running and both devices are on the same WiFi network.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Getting your location...',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Please grant location permission',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  ref.invalidate(currentLocationProvider);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Location Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(currentLocationProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    // Show businesses without location (fallback)
                    // For now, just retry
                    ref.invalidate(currentLocationProvider);
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Show All Businesses'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hardware':
        return Icons.hardware;
      case 'groceries':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'pharmacy':
        return Icons.local_pharmacy;
      case 'electronics':
        return Icons.devices;
      case 'clothing':
        return Icons.checkroom;
      default:
        return Icons.store;
    }
  }
}
