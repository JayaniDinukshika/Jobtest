import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:job/screens/checkout_screen.dart';
import 'package:job/screens/success_screen.dart';
import 'package:provider/provider.dart'; // Add provider import
import 'package:job/providers/cart_provider.dart'; // Import CartProvider
import 'package:job/screens/cart_screen.dart'; // Ensure correct case (CartScreen)
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(), // Create CartProvider instance
      child: MaterialApp(
        title: 'E-Commerce App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/checkout': (context) => const CheckoutScreen(),
          '/success': (context) => const SuccessScreen(),// Replace with CheckoutScreen
        },
      ),
    );
  }
}