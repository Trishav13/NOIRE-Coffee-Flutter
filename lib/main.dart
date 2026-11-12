import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/coffee_shop_provider.dart';
import 'home_page.dart';
import 'constants.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [ChangeNotifierProvider(create: (_) => CoffeeShopProvider())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'NOIRÉ Coffee',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark),
      useMaterial3: true,
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.accent),
    ),
    home: const HomePage(),
  );
}
