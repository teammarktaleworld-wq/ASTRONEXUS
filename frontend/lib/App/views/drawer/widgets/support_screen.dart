import 'package:flutter/material.dart';
import 'package:astro_tale/core/widgets/unified_dark_ui.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: UnifiedDarkUi.appBar(context, title: "Support"),
      body: const Center(
        child: Text("Support Screen", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
