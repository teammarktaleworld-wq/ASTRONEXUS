import 'package:astro_tale/App/Model/cart_model.dart';
import 'package:astro_tale/App/Model/address_model.dart';
import 'package:astro_tale/App/views/shop/checkout/add_address_screen.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:astro_tale/App/views/shop/checkout/payment_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:astro_tale/services/api_services/adress_api.dart';
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
  final AddressApi _addressApi = AddressApi();

  Address? selectedAddress;
  List<Address> addresses = <Address>[];
  bool addressLoading = true;
  bool loading = false;
  String paymentMethod = "UPI"; // default payment method

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (mounted) {
      setState(() => addressLoading = true);
    }

    try {
      final fetched = await _addressApi.getUserAddresses(
        token: widget.userToken,
      );
      final defaultAddress = fetched.isEmpty
          ? null
          : fetched.firstWhere((a) => a.isDefault, orElse: () => fetched.first);

      if (!mounted) {
        return;
      }

      Address? retained;
      if (selectedAddress != null) {
        for (final a in fetched) {
          if (a.id == selectedAddress!.id) {
            retained = a;
            break;
          }
        }
      }

      setState(() {
        addresses = fetched;
        selectedAddress = retained ?? defaultAddress;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        addresses = <Address>[];
        selectedAddress = null;
      });
    } finally {
      if (mounted) {
        setState(() => addressLoading = false);
      }
    }
  }

  Future<void> _addAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAddressScreen(token: widget.userToken),
      ),
    );
    _loadAddresses();
  }

  Future<void> _editAddress(Address address) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddAddressScreen(token: widget.userToken, existing: address),
      ),
    );
    _loadAddresses();
  }

  Future<void> _deleteAddress(Address address) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Address"),
        content: Text("Remove address for ${address.fullName}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    await _addressApi.deleteAddress(
      token: widget.userToken,
      addressId: address.id,
    );

    if (!mounted) {
      return;
    }

    if (selectedAddress?.id == address.id) {
      selectedAddress = null;
    }

    _loadAddresses();
  }

  Color _shimmerBase(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.black.withValues(alpha: 0.08);
  }

  Color _shimmerHighlight(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark
        ? Colors.white.withValues(alpha: 0.26)
        : Colors.black.withValues(alpha: 0.14);
  }

  Widget _shimmerBlock({
    required ThemeData theme,
    required double height,
    double width = double.infinity,
    double radius = 10,
    EdgeInsetsGeometry margin = EdgeInsets.zero,
  }) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: _shimmerBase(theme),
        highlightColor: _shimmerHighlight(theme),
        period: const Duration(milliseconds: 1150),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }

  Widget _addressShimmer(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedDarkUi.cardSurface(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shimmerBlock(theme: theme, width: 150, height: 18, radius: 8),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _shimmerBlock(
                        theme: theme,
                        height: 16,
                        width: 140,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _shimmerBlock(
                      theme: theme,
                      height: 20,
                      width: 64,
                      radius: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _shimmerBlock(theme: theme, height: 12, width: double.infinity),
                const SizedBox(height: 8),
                _shimmerBlock(theme: theme, height: 12, width: 220),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _shimmerBlock(
                      theme: theme,
                      height: 34,
                      width: 92,
                      radius: 10,
                    ),
                    const SizedBox(width: 10),
                    _shimmerBlock(
                      theme: theme,
                      height: 34,
                      width: 92,
                      radius: 10,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _shimmerBlock(theme: theme, height: 40, width: 170, radius: 10),
        ],
      ),
    );
  }

  Widget _addressSection(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : theme.colorScheme.onSurface;
    final subColor = isDark
        ? Colors.white70
        : theme.colorScheme.onSurface.withValues(alpha: 0.72);

    if (addressLoading) {
      return _addressShimmer(theme);
    }

    if (addresses.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: UnifiedDarkUi.cardSurface(theme),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "No address selected",
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Add a delivery address to continue checkout.",
              style: GoogleFonts.dmSans(color: subColor),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addAddress,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text("Add Address"),
            ),
          ],
        ),
      );
    }

    final others = addresses.where((a) => a.id != selectedAddress?.id).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UnifiedDarkUi.cardSurface(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Delivery Address",
            style: GoogleFonts.dmSans(
              color: titleColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (selectedAddress != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: UnifiedDarkUi.cardBorder(theme)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          selectedAddress!.fullName,
                          style: GoogleFonts.dmSans(
                            color: titleColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (selectedAddress!.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            "Default",
                            style: GoogleFonts.dmSans(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${selectedAddress!.street}, ${selectedAddress!.city}, ${selectedAddress!.state}",
                    style: GoogleFonts.dmSans(color: subColor, fontSize: 13),
                  ),
                  Text(
                    "${selectedAddress!.country} - ${selectedAddress!.postalCode}",
                    style: GoogleFonts.dmSans(color: subColor, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _editAddress(selectedAddress!),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text("Update"),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _deleteAddress(selectedAddress!),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (others.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "Other Addresses",
              style: GoogleFonts.dmSans(
                color: titleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...others.map(
              (addr) => Column(
                children: [
                  RadioListTile<String>(
                    value: addr.id,
                    groupValue: selectedAddress?.id,
                    onChanged: (_) => setState(() => selectedAddress = addr),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      addr.fullName,
                      style: GoogleFonts.dmSans(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      "${addr.street}, ${addr.city}",
                      style: GoogleFonts.dmSans(color: subColor, fontSize: 12),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 42),
                      TextButton.icon(
                        onPressed: () => _editAddress(addr),
                        icon: const Icon(Icons.edit_outlined, size: 15),
                        label: const Text("Update"),
                      ),
                      TextButton.icon(
                        onPressed: () => _deleteAddress(addr),
                        icon: const Icon(Icons.delete_outline, size: 15),
                        label: const Text("Delete"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _addAddress,
            icon: const Icon(Icons.add_location_alt_rounded),
            label: const Text("Add Another Address"),
          ),
        ],
      ),
    );
  }

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
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _addressSection(theme),
                                const SizedBox(height: 16),

                                // PAYMENT METHOD SELECTOR
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final isDark =
                                            Theme.of(context).brightness ==
                                            Brightness.dark;
                                        final textColor = isDark
                                            ? Colors.white
                                            : const Color(0xFF332D56);
                                        final dropDownColor = isDark
                                            ? UnifiedDarkUi.cardSurfaceAlt(
                                                theme,
                                              )
                                            : Colors.white;

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Payment Method",
                                              style: GoogleFonts.dmSans(
                                                color: isDark
                                                    ? Colors.white70
                                                    : const Color(0xFF555879),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                          alpha: 0.45,
                                                        ),
                                                    blurRadius: 12,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                    ),
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color:
                                                      UnifiedDarkUi.cardSurface(
                                                        theme,
                                                      ),
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color:
                                                        UnifiedDarkUi.cardBorder(
                                                          theme,
                                                        ),
                                                    width: 1.2,
                                                  ),
                                                ),
                                                child: DropdownButtonHideUnderline(
                                                  child: DropdownButton<String>(
                                                    value: paymentMethod,
                                                    isExpanded: true,
                                                    dropdownColor:
                                                        dropDownColor,
                                                    icon: Icon(
                                                      Icons
                                                          .keyboard_arrow_down_rounded,
                                                      color: textColor,
                                                      size: 28,
                                                    ),
                                                    style: GoogleFonts.dmSans(
                                                      color: textColor,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    items: [
                                                      DropdownMenuItem(
                                                        value: "UPI",
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .account_balance_wallet_outlined,
                                                              color:
                                                                  Colors.green,
                                                              size: 24,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Text(
                                                              "Online Payment",
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        value: "CASH",
                                                        child: Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .payments_outlined,
                                                              color:
                                                                  Colors.orange,
                                                              size: 24,
                                                            ),
                                                            const SizedBox(
                                                              width: 12,
                                                            ),
                                                            Text(
                                                              "Cash on Delivery",
                                                            ),
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
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                                  theme.brightness == Brightness.dark
                                  ? Colors.amberAccent
                                  : theme.colorScheme.primary,
                              foregroundColor:
                                  theme.brightness == Brightness.dark
                                  ? Colors.black
                                  : theme.colorScheme.onPrimary,
                              disabledBackgroundColor:
                                  theme.brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.14)
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.12,
                                    ),
                              disabledForegroundColor:
                                  theme.brightness == Brightness.dark
                                  ? Colors.white70
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.55,
                                    ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
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
                                    color: theme.brightness == Brightness.dark
                                        ? Colors.black
                                        : theme.colorScheme.onPrimary,
                                    size: 16,
                                  )
                                : Text(
                                    paymentMethod == "UPI"
                                        ? "Proceed to Payment"
                                        : "Place Order (Cash)",
                                    style: GoogleFonts.dmSans(
                                      fontWeight: FontWeight.w600,
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
