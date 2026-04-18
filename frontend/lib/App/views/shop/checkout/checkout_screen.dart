import 'package:astro_tale/App/Model/cart_model.dart';
import 'package:astro_tale/App/Model/address_model.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:astro_tale/App/views/shop/checkout/payment_screen.dart';
import 'package:astro_tale/App/views/shop/widgets/address_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:astro_tale/services/api_services/order_api.dart';
import 'package:astro_tale/services/api_services/payment_api.dart';

class CheckoutScreen extends StatefulWidget {
  final CartModel? cart;
  final String userToken;

  const CheckoutScreen({super.key, this.cart, required this.userToken});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address? selectedAddress;
  bool loading = false;
  String paymentMethod = "UPI"; // default payment method

  @override
  Widget build(BuildContext context) {
    final cart = widget.cart;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(context, title: "Checkout"),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: cart == null
                  ? Center(
                      child: Text(
                        "Your cart is empty",
                        style: GoogleFonts.dmSans(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: AddressWidget(
                            userToken: widget.userToken,
                            onAddressSelected: (addr) {
                              setState(() {
                                selectedAddress = addr;
                              });
                            },
                            selectedAddress: selectedAddress,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // PAYMENT METHOD SELECTOR
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(
                          "Payment Method",
                          style: GoogleFonts.dmSans(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white70
                                : const Color(0xFF555879), // soft royal tone for light theme
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                            const SizedBox(height: 8),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                height: 60,
                                decoration: BoxDecoration(
                                  color: UnifiedDarkUi.cardSurface(theme),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: UnifiedDarkUi.cardBorder(theme),
                                    width: 1.2,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: paymentMethod,
                                    isExpanded: true,
                                    dropdownColor: UnifiedDarkUi.cardSurfaceAlt(
                                      theme,
                                    ),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    style: GoogleFonts.dmSans(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    items: const [
                                      DropdownMenuItem(
                                        value: "UPI",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .account_balance_wallet_outlined,
                                              color: Colors.green,
                                              size: 24,
                                            ),
                                            SizedBox(width: 12),
                                            Text("Online Payment"),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: "CASH",
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.payments_outlined,
                                              color: Colors.orange,
                                              size: 24,
                                            ),
                                            SizedBox(width: 12),
                                            Text("Cash on Delivery"),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (val) {
                                      setState(() {
                                        paymentMethod = val!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedAddress == null
                                ? null
                                : () async {
                                    setState(() => loading = true);

                                    try {
                                      // 1️⃣ Place order
                                      final order = await OrderApi().placeOrder(
                                        addressId: selectedAddress!.id,
                                        paymentMethod: paymentMethod,
                                      );

                                      setState(() => loading = false);
                                      if (!context.mounted) return;

                                      if (order != null) {
                                        if (paymentMethod == "UPI") {
                                          // Online payment: go to payment screen
                                          final payment = await PaymentApi()
                                              .createPayment(order.totalAmount);
                                          if (!context.mounted) return;
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PaymentScreen(
                                                order: order,
                                                payment: payment,
                                                userToken: widget.userToken,
                                              ),
                                            ),
                                          );
                                        } else {
                                          // Cash on Delivery: show success dialog
                                          await showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (_) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .white, // Light background
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                  border: Border.all(
                                                    color: Colors.grey.shade300,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                            alpha: 0.15,
                                                          ),
                                                      blurRadius: 12,
                                                      offset: const Offset(
                                                        0,
                                                        6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    /// Success Icon
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors
                                                            .greenAccent
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                        shape: BoxShape.circle,
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                            20,
                                                          ),
                                                      child: const Icon(
                                                        Icons
                                                            .check_circle_outline,
                                                        color:
                                                            Colors.greenAccent,
                                                        size: 64,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),

                                                    /// Title
                                                    Text(
                                                      "Order Placed Successfully!",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 12),

                                                    /// Subtitle
                                                    Text(
                                                      "You can pay on delivery. Thank you for shopping with us!",
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 15,
                                                          ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    const SizedBox(height: 28),

                                                    /// Go to Shop Button
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          ); // close dialog
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          ); // optional extra pops
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.green,
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                          elevation: 6,
                                                          shadowColor: Colors
                                                              .greenAccent
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                        ),
                                                        child: Text(
                                                          "Go to Shop",
                                                          style:
                                                              GoogleFonts.poppins(
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Failed to place order",
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() => loading = false);
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  },
                            child: loading
                                ? LoadingAnimationWidget.fourRotatingDots(
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : Text(
                                    paymentMethod == "UPI"
                                        ? "Proceed to Payment"
                                        : "Place Order (Cash)",
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
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
      decoration: UnifiedDarkUi.screenBackground(Theme.of(context)),
    );
  }
}
