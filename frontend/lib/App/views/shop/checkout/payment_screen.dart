import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../services/api_services/payment_api.dart';
import '../../../Model/order_model.dart';
import '../../../Model/payment_model.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel order;
  final String userToken;

  const PaymentScreen({
    super.key,
    required this.order,
    required this.userToken,
    required payment,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentApi _paymentApi = PaymentApi();
  String? selectedMethod;
  bool loading = false;

  List<String> paymentMethods = ["UPI", "Card", "Wallet", "Net Banking"];

  Future<void> _makePayment() async {
    if (selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a payment method")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1️⃣ Create payment
      PaymentModel payment = await _paymentApi.createPayment(
        widget.order.totalAmount,
      );

      // 2️⃣ Simulate transaction id (for demo)
      String transactionId = "TXN${DateTime.now().millisecondsSinceEpoch}";

      // 3️⃣ Verify payment
      bool success = await _paymentApi.verifyPayment(
        paymentId: payment.id,
        transactionId: transactionId,
      );

      setState(() => loading = false);

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Payment Successful!")));
        // Navigate to dashboard or order success screen
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Payment Failed")));
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Payment",
          style: GoogleFonts.dmSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ====== ORDER SUMMARY ======
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff393053),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Summary",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.order.items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${item.product?.name ?? "Item"} x${item.quantity}",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  "₹${(item.price * item.quantity).toStringAsFixed(2)}",
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Divider(color: Colors.white24, height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total",
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "₹${widget.order.totalAmount.toStringAsFixed(2)}",
                              style: GoogleFonts.dmSans(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ====== PAYMENT METHODS ======
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xff393053),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Payment Method",
                          style: GoogleFonts.dmSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...paymentMethods.map((method) {
                          return RadioListTile<String>(
                            activeColor: Colors.amberAccent,
                            title: Text(
                              method,
                              style: GoogleFonts.dmSans(color: Colors.white70),
                            ),
                            value: method,
                            groupValue: selectedMethod,
                            onChanged: (val) {
                              setState(() {
                                selectedMethod = val;
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // ====== PAY BUTTON ======
                  ElevatedButton(
                    onPressed: loading ? null : _makePayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : Text(
                            "Pay ₹${widget.order.totalAmount.toStringAsFixed(2)}",
                            style: GoogleFonts.dmSans(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xff393053), Color(0xff393053), Color(0xff050B1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
