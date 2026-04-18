import 'dart:ui';
import 'package:astro_tale/App/Model/address_model.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:astro_tale/services/api_services/adress_api.dart';

class AddAddressScreen extends StatefulWidget {
  final String token;
  final Address? existing;

  const AddAddressScreen({super.key, required this.token, this.existing});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final AddressApi _api = AddressApi();

  late TextEditingController fullName;
  late TextEditingController phone;
  late TextEditingController street;
  late TextEditingController city;
  late TextEditingController state;
  late TextEditingController country;
  late TextEditingController postalCode;
  bool isDefault = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    fullName = TextEditingController(text: a?.fullName);
    phone = TextEditingController(text: a?.phone);
    street = TextEditingController(text: a?.street);
    city = TextEditingController(text: a?.city);
    state = TextEditingController(text: a?.state);
    country = TextEditingController(text: a?.country ?? "India");
    postalCode = TextEditingController(text: a?.postalCode);
    isDefault = a?.isDefault ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final address = Address(
      id: widget.existing?.id ?? "",
      userId: "",
      fullName: fullName.text,
      phone: phone.text,
      street: street.text,
      city: city.text,
      state: state.text,
      country: country.text,
      postalCode: postalCode.text,
      isDefault: isDefault,
    );

    try {
      if (widget.existing == null) {
        await _api.addAddress(token: widget.token, address: address);
      } else {
        await _api.updateAddress(token: widget.token, address: address);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (!mounted) return;
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(
        context,
        title: widget.existing == null ? "Add Address" : "Edit Address",
      ),

      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _field(fullName, "Full Name"),
                    _field(phone, "Phone"),
                    _field(street, "Street"),
                    _field(city, "City"),
                    _field(state, "State"),
                    _field(country, "Country"),
                    _field(postalCode, "Postal Code"),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withValues(alpha: 0.05),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SwitchListTile(
                        value: isDefault,
                        onChanged: (v) => setState(() => isDefault = v),
                        title: const Text(
                          "Set as default address",
                          style: TextStyle(color: Colors.white70),
                        ),
                        activeThumbColor: Colors.amberAccent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(alignment: Alignment.center, child: _saveButton()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Focus(
        onFocusChange: (_) => setState(() {}),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isDark
                ? LinearGradient(
              colors: [
                Colors.white.withOpacity(0.02),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : LinearGradient(
              colors: [
                Colors.white,
                const Color(0xFFF4F6FF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: isDark
                ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: _buildTextField(controller, label, isDark),
            )
                : _buildTextField(controller, label, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      bool isDark,
      ) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.dmSans(
        color: isDark ? Colors.white : const Color(0xFF332D56),
        fontWeight: FontWeight.w500,
      ),
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          color: isDark
              ? Colors.white70
              : const Color(0xFF555879),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white24
                : const Color(0xFF555879).withOpacity(0.25),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: isDark
                ? Colors.amberAccent
                : const Color(0xFF332D56),
            width: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _saveButton() {
    return GestureDetector(
      onTap: _save,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12), // pill shape
          gradient: const LinearGradient(
            colors: [Color(0xffFFD54F), Color(0xffFFC107)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: loading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(
                "Save Address",
                style: GoogleFonts.dmSans(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  Widget _background() {
    return Container(
      decoration: UnifiedDarkUi.screenBackground(Theme.of(context)),
    );
  }
}
