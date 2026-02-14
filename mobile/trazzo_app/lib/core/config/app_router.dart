import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/customer/screens/customer_home_screen.dart';
import '../../features/customer/screens/business_list_screen.dart';
import '../../features/customer/screens/business_details_screen.dart';
import '../../features/customer/screens/chat_screen.dart';
import '../../features/customer/screens/order_create_screen.dart';
import '../../features/customer/screens/order_list_screen.dart';
import '../../features/customer/screens/order_detail_screen.dart';
import '../../features/business/screens/business_home_screen.dart';
import '../../features/business/screens/business_onboarding_screen.dart';
import '../../features/business/screens/business_chat_screen.dart';
import '../../features/business/screens/business_order_detail_screen.dart';
import '../../features/rider/screens/rider_home_screen.dart';
import '../../core/services/auth_service.dart';
import '../../shared/models/user_role.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authService = ref.watch(authServiceProvider);
  
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) async {
      final isLoggedIn = await authService.isLoggedIn();
      final isLoginRoute = state.matchedLocation == '/login' || 
                          state.matchedLocation == '/register';
      
      // If not logged in and trying to access protected route
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      
      // If logged in and on login/register, redirect to home
      if (isLoggedIn && isLoginRoute) {
        final role = await authService.getCurrentUserRole();
        return _getHomeRouteForRole(role);
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerHomeScreen(),
        routes: [
          GoRoute(
            path: 'businesses',
            builder: (context, state) => const BusinessListScreen(),
          ),
          GoRoute(
            path: 'business/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BusinessDetailsScreen(businessId: id);
            },
          ),
          GoRoute(
            path: 'chat/:businessId',
            builder: (context, state) {
              final businessId = int.parse(state.pathParameters['businessId']!);
              return ChatScreen(businessId: businessId);
            },
          ),
          GoRoute(
            path: 'orders',
            builder: (context, state) => const OrderListScreen(),
          ),
          GoRoute(
            path: 'order/create/:businessId',
            builder: (context, state) {
              final businessId = int.parse(state.pathParameters['businessId']!);
              return OrderCreateScreen(businessId: businessId);
            },
          ),
          GoRoute(
            path: 'order/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return OrderDetailScreen(orderId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/business',
        builder: (context, state) => const BusinessHomeScreen(),
        routes: [
          GoRoute(
            path: 'onboarding',
            builder: (context, state) => const BusinessOnboardingScreen(),
          ),
          GoRoute(
            path: 'chat/:chatId',
            builder: (context, state) {
              final chatId = int.parse(state.pathParameters['chatId']!);
              final customerName = state.uri.queryParameters['customerName'] ?? 'Customer';
              return BusinessChatScreen(
                chatId: chatId,
                customerName: Uri.decodeComponent(customerName),
              );
            },
          ),
          GoRoute(
            path: 'order/:id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return BusinessOrderDetailScreen(orderId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/rider',
        builder: (context, state) => const RiderHomeScreen(),
      ),
    ],
  );
});

String _getHomeRouteForRole(UserRole? role) {
  switch (role) {
    case UserRole.customer:
      return '/customer';
    case UserRole.business:
      return '/business';
    case UserRole.rider:
      return '/rider';
    default:
      return '/login';
  }
}
