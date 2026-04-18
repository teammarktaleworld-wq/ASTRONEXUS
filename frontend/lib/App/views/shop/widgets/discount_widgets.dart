import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../services/api_services/discount_services.dart';
import '../../../Model/place/discount_model.dart';

class ApplyDiscountWidget extends StatefulWidget {
  final double cartTotal;
  final Function(double) onDiscountApplied;

  const ApplyDiscountWidget({
    super.key,
    required this.cartTotal,
    required this.onDiscountApplied,
  });

  @override
  State<ApplyDiscountWidget> createState() => _ApplyDiscountWidgetState();
}

class _ApplyDiscountWidgetState extends State<ApplyDiscountWidget> {
  void _openCouponSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CouponBottomSheet(
        cartTotal: widget.cartTotal,
        onDiscountApplied: widget.onDiscountApplied,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openCouponSheet,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: const [
            Icon(Icons.local_offer_outlined, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Apply Coupon",
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.black38,
            ),
          ],
        ),
      ),
    );
  }
}

class CouponBottomSheet extends StatefulWidget {
  final double cartTotal;
  final Function(double) onDiscountApplied;

  const CouponBottomSheet({
    super.key,
    required this.cartTotal,
    required this.onDiscountApplied,
  });

  @override
  State<CouponBottomSheet> createState() => _CouponBottomSheetState();
}

class _CouponBottomSheetState extends State<CouponBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool loading = false;
  String? error;

  List<Discount> coupons = [];
  bool loadingCoupons = true;

  @override
  void initState() {
    super.initState();
    _loadCoupons();
  }

  Future<void> _applyCoupon(String code) async {
    if (code.isEmpty) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await DiscountService.applyDiscount(
        code: code,
        amount: widget.cartTotal,
      );

      widget.onDiscountApplied(result['finalAmount']);
      Navigator.pop(context);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _loadCoupons() async {
    try {
      final data = await DiscountService.getDiscounts();
      setState(() => coupons = data);
    } catch (_) {}
    setState(() => loadingCoupons = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white70.withOpacity(0.9),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Title
            Text(
              "Available Coupons",
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),

            Divider(),

            const SizedBox(height: 18),

            /// Coupon List
            if (loadingCoupons)
              Column(children: List.generate(3, (_) => _shimmerCouponTile()))
            else if (coupons.isEmpty)
              const Text(
                "No coupons available",
                style: TextStyle(color: Colors.black54),
              )
            else
              ...coupons.map((c) => _couponTile(c)).toList(),

            const SizedBox(height: 22),

            /// Coupon Input
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18), // deeper shadow
                    blurRadius: 28,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.dmSans(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: "ENTER COUPON CODE",
                  hintStyle: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                    color: Colors.black38,
                  ),
                  prefixIcon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Color(0xFF16A34A), // green accent
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            /// Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading
                    ? null
                    : () => _applyCoupon(_controller.text.trim()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff393053),
                  elevation: 10,
                  shadowColor: Colors.black.withOpacity(0.45),
                  padding: const EdgeInsets.symmetric(vertical: 17),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: loading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: LoadingAnimationWidget.fourRotatingDots(
                          color: Colors.black54,
                          size: 22,
                        ),
                      )
                    : const Text(
                        "Apply Coupon",
                        style: TextStyle(
                          fontSize: 15.8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
              ),
            ),

            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// REAL COUPON CARD
  Widget _couponTile(Discount discount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          /// LEFT GREEN STRIP (Coupon Style)
          Container(
            width: 10,
            height: 96,
            decoration: const BoxDecoration(
              color: Color(0xff393053), // Dark green
              borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
            ),
          ),

          const SizedBox(width: 14),

          /// COUPON ICON
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff393053).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: Color(0xff393053),
              size: 22,
            ),
          ),

          const SizedBox(width: 14),

          /// COUPON TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  discount.code,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Save ${discount.percentage}% on your order",
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          /// APPLY BUTTON
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: ElevatedButton(
              onPressed: () => _applyCoupon(discount.code),
              style: ElevatedButton.styleFrom(
                elevation: 4,
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                "APPLY",
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  letterSpacing: 0.6,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Ticket cut circle
  Widget _ticketCut() {
    return Container(
      height: 20,
      width: 20,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }

  /// SHIMMER LOADING CARD
  Widget _shimmerCouponTile() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.white,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 80, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
