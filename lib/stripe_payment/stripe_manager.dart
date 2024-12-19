import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_payment_app/stripe_payment/stripe_keys.dart';
// الأستاذ باسل مصطفى يوتيوب
abstract class PaymentManager {
  static Future<void> makePayment(
      BuildContext context, int amount, String currency,
      {int timeoutInSeconds = 300}) async {
    try {
      // الحصول على clientSecret من Stripe API
      String? clientSecret =
          await _getClientSecret((amount * 100).toString(), currency);

      // تهيئة الـ Payment Sheet
      await _initPaymentSheet(clientSecret);

      // البدء في الـ Payment Sheet مع تعيين مؤقت
      var paymentFuture = Stripe.instance.presentPaymentSheet();

      // الانتظار لفترة معينة (Timeout) قبل عرض رسالة
      await paymentFuture.timeout(
        Duration(seconds: timeoutInSeconds),
        onTimeout: () {
          // عرض رسالة منبثقة (Dialog) لتوضيح انتهاء وقت الانتظار
          _showTimeoutDialog(context,
              "انتهت فترة الانتظار بدون إتمام الدفع. يُرجى إغلاق شاشة الدفع يدويًا وإعادة المحاولة.");
          return null;
        },
      );
    } catch (e) {
      if (e is StripeException && e.error.code == FailureCode.Canceled) {
        // حالة إغلاق الـ Payment Sheet من قبل المستخدم
        _showTimeoutDialog(
            context, "تم إغلاق الـ Payment Sheet بدون إتمام الدفع");
      } else if (e.toString().contains("Expired")) {
        // حالة انتهاء صلاحية الـ PaymentIntent
        _showTimeoutDialog(
            context, "انتهت صلاحية الدفع. يُرجى إعادة المحاولة.");
      } else {
        // معالجة أي أخطاء أخرى
        _showTimeoutDialog(context, "حدث خطأ غير متوقع أثناء الدفع.");
      }
    }
  }

  // تهيئة الـ Payment Sheet
  static Future<void> _initPaymentSheet(String clientSecret) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: "diana",
      ),
    );
  }

  // الحصول على client_secret من Stripe API
  static Future<String> _getClientSecret(String amount, String currency) async {
    Dio dio = Dio();
    var response = await dio.post(
      'https://api.stripe.com/v1/payment_intents',
      options: Options(
        headers: {
          'Authorization': 'Bearer ${StripeKeys.secretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      ),
      data: {
        'amount': amount,
        'currency': currency,
      },
    );
    return response.data["client_secret"];
  }

  // دالة لإظهار نافذة منبثقة عند انتهاء المهلة
  static void _showTimeoutDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("تنبيه"),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text("موافق"),
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الـ Dialog
              },
            ),
          ],
        );
      },
    );
  }
}
