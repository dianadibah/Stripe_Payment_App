import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment_app/stripe_payment/stripe_keys.dart';
import 'package:stripe_payment_app/stripe_payment/stripe_manager.dart';

void main() {
  Stripe.publishableKey = StripeKeys.publishedKey;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strpe Payment'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              color: Colors.blueAccent,
              onPressed: () async {
                await PaymentManager.makePayment(context, 20, "USD");
              },
              child: const Text(
                "Pay 20\$",
                style: TextStyle(color: Colors.white),
              ),
            ),
            MaterialButton(
              color: Colors.amber,
              onPressed: () async {
                await PaymentManager.makePayment(context, 3000, "USD");
              },
              child: const Text(
                "Pay 3000\$",
                style: TextStyle(color: Colors.white),
              ),
            ),
            MaterialButton(
              color: Colors.redAccent,
              onPressed: () async {
                await PaymentManager.makePayment(context, 500, "USD");
              },
              child: const Text(
                "Pay 500\$",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
