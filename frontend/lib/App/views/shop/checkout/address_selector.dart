import 'package:astro_tale/App/Model/address_model.dart';
import 'package:astro_tale/App/views/shop/checkout/add_address_screen.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:astro_tale/services/api_services/adress_api.dart';

class AddressSelector extends StatefulWidget {
  final String token;

  const AddressSelector({super.key, required this.token});

  @override
  State<AddressSelector> createState() => _AddressSelectorState();
}

class _AddressSelectorState extends State<AddressSelector> {
  final AddressApi _api = AddressApi();

  List<Address> addresses = [];
  bool loading = true;
  Address? selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => loading = true);
    try {
      addresses = await _api.getUserAddresses(token: widget.token);
      if (addresses.isNotEmpty) {
        selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setState(() => loading = false);
  }

  Future<void> _deleteAddress(String id) async {
    await _api.deleteAddress(token: widget.token, addressId: id);
    _loadAddresses();
  }

  void _confirmSelection() {
    if (selectedAddress != null) {
      Navigator.pop(context, selectedAddress);
    }
  }

  Future<void> _navigateToAddAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddAddressScreen(token: widget.token)),
    );
    _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(
        context,
        title: "Select Address",
        actions: [
          IconButton(
            tooltip: "Add Address",
            onPressed: _navigateToAddAddress,
            icon: const Icon(
              Icons.add_location_alt_rounded,
              color: Colors.amberAccent,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: loading
                ? _shimmerLoader()
                : addresses.isEmpty
                ? _emptyState()
                : Column(
                    children: [
                      Expanded(child: _addressList()),
                      _deliverHereButton(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ================= SHIMMER =================
  Widget _shimmerLoader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: isDark ? Colors.white12 : Colors.grey.shade300,
        highlightColor: isDark ? Colors.white24 : Colors.grey.shade100,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          height: 100,
          decoration: BoxDecoration(
            color: isDark ? Colors.white12 : Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ================= LIST =================
  Widget _addressList() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: addresses.length,
      itemBuilder: (context, index) {
        final addr = addresses[index];
        final isSelected = addr == selectedAddress;

        final primaryText = isDark
            ? Colors.white
            : const Color(0xFF332D56);

        final secondaryText = isDark
            ? Colors.amberAccent
            : const Color(0xFF555879);

        final shadowColor = isDark
            ? Colors.black.withOpacity(0.35)
            : Colors.black.withOpacity(0.08);

        final baseGradient = isDark
            ? [
          UnifiedDarkUi.cardSurface(theme),
          UnifiedDarkUi.cardSurfaceAlt(theme),
        ]
            : [
          Colors.white,
          const Color(0xFFF4F6FF),
        ];

        final selectedGradient = isDark
            ? [
          Colors.amberAccent.withOpacity(0.24),
          UnifiedDarkUi.cardSurfaceAlt(theme),
        ]
            : [
          const Color(0xFF332D56).withOpacity(0.08),
          Colors.white,
        ];

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              colors: isSelected ? selectedGradient : baseGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isSelected
                  ? (isDark
                  ? Colors.amberAccent
                  : const Color(0xFF332D56))
                  : (isDark
                  ? UnifiedDarkUi.cardBorder(theme)
                  : const Color(0xFF555879).withOpacity(0.2)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => setState(() => selectedAddress = addr),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(top: 4),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? Colors.amberAccent
                              : const Color(0xFF332D56),
                          width: 2,
                        ),
                        color: isSelected
                            ? (isDark
                            ? Colors.amberAccent
                            : const Color(0xFF332D56))
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                        Icons.check,
                        size: 14,
                        color: isDark
                            ? Colors.black
                            : Colors.white,
                      )
                          : null,
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: addr.fullName,
                              style: TextStyle(
                                color: primaryText,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            const TextSpan(text: "\n"),
                            TextSpan(
                              text: "${addr.street}, ${addr.city}\n",
                              style: TextStyle(
                                color: secondaryText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: "${addr.state} - ${addr.postalCode}",
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _deleteAddress(addr.id),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: isDark
                              ? Colors.white38
                              : Colors.black38,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ================= CTA =================
  Widget _deliverHereButton() {
    final isEnabled = selectedAddress != null;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SizedBox(
          width: double.infinity, // Full-width button
          height: 56,
          child: Material(
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: isEnabled ? _confirmSelection : null,
              child: Container(
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [Colors.amberAccent, Colors.amberAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Deliver to this address",
                  style: GoogleFonts.dmSans(
                    color: isEnabled
                        ? Colors.grey.shade900
                        : Colors.grey.shade500,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= EMPTY =================
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off, color: Colors.white38, size: 64),
          const SizedBox(height: 12),
          const Text(
            "No address found",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _navigateToAddAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Add Address",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  // ================= BACKGROUND =================
  Widget _background() {
    return Container(
      decoration: UnifiedDarkUi.screenBackground(Theme.of(context)),
    );
  }
}
