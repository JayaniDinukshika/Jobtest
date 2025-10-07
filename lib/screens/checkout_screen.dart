import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _makePayment() async {
    try {
      // ⚠️ WARNING: This uses your secret key in Flutter (unsafe for production)
      const secretKey = "pk_test_51SFVVkFMGZaOfBRBlQMy9hFqSCZhAJN5Mmg7Ax4YauIjqhbHt3jhocy0OTC0AfMlw6ub2hrdqktcgFsEvknhaPAU00h40fAOlC"; // Replace with your test secret key
      const amount = 1000; // $10.00 in cents

      // 1. Create PaymentIntent directly from Stripe API
      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          "amount": amount.toString(),
          "currency": "usd",
          "payment_method_types[]": "card",
        },
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to create PaymentIntent: ${response.body}");
      }

      final paymentIntent = jsonDecode(response.body);
      final clientSecret = paymentIntent['client_secret'];

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "My Shop",
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // ✅ Success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Payment successful!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // ❌ Failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Payment failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: Colors.amber),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
                validator: (val) => val!.isEmpty ? "Enter address" : null,
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.white),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _makePayment();
                  }
                },
                child: const Text("Confirm & Pay"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
