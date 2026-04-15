import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'features/transaction/presentation/transaction_form_view.dart';

void main() {
  runApp(
    const ProviderScope(
      child: AkgMasterApp(),
    ),
  );
}

class AkgMasterApp extends StatelessWidget {
  const AkgMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AKG Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TransactionFormView(),
    );
  }
}
