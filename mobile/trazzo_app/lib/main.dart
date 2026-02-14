import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/app_router.dart';
import '../core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: TrazzoApp(),
    ),
  );
}

class TrazzoApp extends ConsumerWidget {
  const TrazzoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Trazzo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
